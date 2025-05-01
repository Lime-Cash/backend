class CreateJoinTableAccountsExternalMethods < ActiveRecord::Migration[8.0]
  def change
    create_join_table :accounts, :external_methods do |t|
      # t.index [:account_id, :external_method_id]
      # t.index [:external_method_id, :account_id]
    end
  end
end
