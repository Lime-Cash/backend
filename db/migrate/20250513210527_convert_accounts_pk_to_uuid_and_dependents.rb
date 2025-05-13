class ConvertAccountsPkToUuidAndDependents < ActiveRecord::Migration[8.0]
  def up
    # === Step 1: Add new UUID columns ===
    add_column :accounts, :uuid, :uuid, default: "gen_random_uuid()", null: false
    add_column :transactions, :account_uuid, :uuid
    add_column :transfers, :from_account_uuid, :uuid
    add_column :transfers, :to_account_uuid, :uuid
    add_column :accounts_external_methods, :account_uuid, :uuid

    # === Step 2: Populate new UUID foreign key columns ===
    execute <<-SQL
      UPDATE transactions
      SET account_uuid = accounts.uuid
      FROM accounts
      WHERE transactions.account_id = accounts.id;
    SQL
    execute <<-SQL
      UPDATE transfers
      SET from_account_uuid = accounts.uuid
      FROM accounts
      WHERE transfers.from_account_id = accounts.id;
    SQL
    execute <<-SQL
      UPDATE transfers
      SET to_account_uuid = accounts.uuid
      FROM accounts
      WHERE transfers.to_account_id = accounts.id;
    SQL
    execute <<-SQL
      UPDATE accounts_external_methods
      SET account_uuid = accounts.uuid
      FROM accounts
      WHERE accounts_external_methods.account_id = accounts.id;
    SQL

    # === Step 3: Perform schema changes within a transaction ===
    transaction do
      # --- Step 3a: Remove existing Foreign Key Constraints depending on accounts.id ---
      remove_foreign_key :transactions, :accounts, if_exists: true
      remove_foreign_key :transfers, :accounts, column: :from_account_id, if_exists: true
      remove_foreign_key :transfers, :accounts, column: :to_account_id, if_exists: true
      # Note: accounts_external_methods.account_id did not have an explicit FK in schema.rb

      # --- Step 3b: Accounts Table - Convert PK to UUID ---
      execute "ALTER TABLE accounts DROP CONSTRAINT IF EXISTS accounts_pkey;"
      remove_column :accounts, :id, type: :bigint, if_exists: true
      rename_column :accounts, :uuid, :id
      execute "ALTER TABLE accounts ADD PRIMARY KEY (id);"

      # --- Step 3c: Transactions Table - Update FK to accounts ---
      remove_index :transactions, name: :index_transactions_on_account_id, if_exists: true
      remove_column :transactions, :account_id, type: :bigint
      rename_column :transactions, :account_uuid, :account_id
      add_foreign_key :transactions, :accounts, column: :account_id, primary_key: :id
      add_index :transactions, :account_id

      # --- Step 3d: Transfers Table - Update FKs to accounts ---
      # from_account_id
      remove_index :transfers, name: :index_transfers_on_from_account_id, if_exists: true
      remove_column :transfers, :from_account_id, type: :bigint
      rename_column :transfers, :from_account_uuid, :from_account_id
      add_foreign_key :transfers, :accounts, column: :from_account_id, primary_key: :id
      add_index :transfers, :from_account_id

      # to_account_id
      remove_index :transfers, name: :index_transfers_on_to_account_id, if_exists: true
      remove_column :transfers, :to_account_id, type: :bigint
      rename_column :transfers, :to_account_uuid, :to_account_id
      add_foreign_key :transfers, :accounts, column: :to_account_id, primary_key: :id
      add_index :transfers, :to_account_id

      # --- Step 3e: Accounts_External_Methods Table - Update FK to accounts ---
      remove_column :accounts_external_methods, :account_id, type: :bigint
      rename_column :accounts_external_methods, :account_uuid, :account_id
      add_foreign_key :accounts_external_methods, :accounts, column: :account_id, primary_key: :id, if_not_exists: true
      change_column_null :accounts_external_methods, :account_id, false # if original was null: false
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Cannot easily revert UUID primary key conversion for accounts and its dependents."
  end
end
