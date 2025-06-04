class RemoveExternalMethods < ActiveRecord::Migration[8.0]
  def change
    # Remove foreign key constraint first
    remove_foreign_key :transactions, :external_methods if foreign_key_exists?(:transactions, :external_methods)

    # Remove the external_method_id column from transactions
    remove_column :transactions, :external_method_id, :bigint

    # Drop the join table
    drop_join_table :accounts, :external_methods if table_exists?(:accounts_external_methods)

    # Drop the external_methods table
    drop_table :external_methods if table_exists?(:external_methods)
  end
end
