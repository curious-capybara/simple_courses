class CreateEnrollments < ActiveRecord::Migration[6.0]
  def change
    create_table :enrollments do |t|
      t.references :user
      t.references :course

      t.timestamps
    end
  end
end
