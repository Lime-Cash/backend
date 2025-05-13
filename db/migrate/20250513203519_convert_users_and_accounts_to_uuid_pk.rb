class ConvertUsersAndAccountsToUuidPk < ActiveRecord::Migration[8.0]
  def up
    # == Users Table ==
    # 1. Add new UUID column to users.
    # The default: "gen_random_uuid()" ensures existing and new rows get a UUID.
    add_column :users, :uuid, :uuid, default: "gen_random_uuid()", null: false

    # == Accounts Table ==
    # 2. Add new UUID column for the foreign key.
    add_column :accounts, :user_uuid, :uuid

    # 3. Populate accounts.user_uuid from users.uuid for existing records.
    # This relies on users.uuid having been populated by the default value.
    execute <<-SQL
      UPDATE accounts
      SET user_uuid = users.uuid
      FROM users
      WHERE accounts.user_id = users.id;
    SQL

    transaction do
      # == Step 1: Modify Accounts Table - Remove old Foreign Key Constraint ==
      # This must be done BEFORE altering the users table primary key.
      remove_foreign_key :accounts, :users, if_exists: true # Safely remove FK by target table

      # == Step 2: Modify Users Table - Switch primary key from integer to UUID ==
      execute "ALTER TABLE users DROP CONSTRAINT IF EXISTS users_pkey;" # Drop old integer PK constraint
      remove_column :users, :id, type: :bigint # Remove old integer id column
      rename_column :users, :uuid, :id # Rename new uuid column to 'id'
      execute "ALTER TABLE users ADD PRIMARY KEY (id);" # Make new 'id' (UUID) the primary key

      # == Step 3: Modify Accounts Table - Finalize Foreign Key switch to UUID ==
      # Remove index on old integer user_id (this might have been removed by remove_foreign_key or might need explicit removal)
      remove_index :accounts, name: :index_accounts_on_user_id, if_exists: true # Original index name
      # Remove old integer user_id column.
      remove_column :accounts, :user_id, type: :bigint

      # Rename new user_uuid column to 'user_id'.
      rename_column :accounts, :user_uuid, :user_id
      # Add new foreign key constraint on user_id (UUID) referencing users.id (UUID).
      # The primary_key option explicitly states which column in the `users` table is being referenced.
      add_foreign_key :accounts, :users, column: :user_id, primary_key: :id
      # Recreate index on new user_id (UUID), ensuring it uses the conventional name if desired.
      add_index :accounts, :user_id # Rails default index name will be index_accounts_on_user_id
    end
  end

  def down
    # Reverting this migration is complex:
    # - Mapping UUIDs back to a consistent integer sequence.
    # - Handling potential data loss or inconsistencies if new UUID-based records were created.
    # - Restoring old primary and foreign key constraints.
    raise ActiveRecord::IrreversibleMigration, "Cannot easily revert UUID primary key conversion for users and accounts."
  end
end
