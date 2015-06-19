FLAGSTR_ATM = %w(permanently_banned admin moderator supporter blogger contributor translator).freeze

class MutateBooleansToFlagsOfUsers < ActiveRecord::Migration
  def up
    add_column :users, :flags, :bigint, default: 0

    User.reset_column_information

    users = User.all

    users.each do |user|
      FLAGSTR_ATM.each_with_index do |flag, index|
        unless user[flag].nil?
          if user[flag]
            user.flags |= 2 ** index
          end
        end
      end
      user.save!
    end

    # THIS REMOVES THE OLD COLUMNS
    FLAGSTR_ATM.each do |flag|
      remove_column :users, flag
    end
  end

  def down
    FLAGSTR_ATM.each do |flag|
      add_column :users, flag, :boolean, default: :false
    end

    User.reset_column_information

    users = User.all

    users.each do |user|
      FLAGSTR_ATM.each_with_index do |flag, index|
        user[flag] = user.flags & (2 ** index) > 0
      end
      user.save!
    end

    remove_column :users, :flag
  end
end
