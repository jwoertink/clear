require "spec"
require "../spec_helper"

module ModelSpec
  class User
    include Clear::Model

    before(:save) { |u| puts "hello world!" }

    column(id : Int32, primary: true)

    column(first_name : String?)
    column(last_name : String?)
    column(middle_name : String?)

    column(notification_preferences : JSON::Any)

    timestamps

    self.table = "users"
  end

  class UserMigration1
    include Clear::Migration

    def change(dir)
      create_table "users" do |t|
        t.text "first_name"
        t.text "last_name"
        t.text "middle_name"

        t.jsonb "notification_preferences", index: "gin", default: Clear::Expression["{}"]

        t.timestamps
      end
    end
  end

  UserMigration1.new.apply(Clear::Migration::Direction::UP)

  describe "Clear::Model" do
    context "fields management" do
      it "can load from array" do
        u = User.new({id: 123})
        u.id.should eq 123
        u.persisted?.should be_false
      end

      it "can detect persistance" do
        u = User.new({id: 1}, persisted: true)
        u.persisted?.should be_true
      end

      it "can detect change in fields" do
        u = User.new({id: 1})
        u.id = 2
        u.update_h.should eq({"id" => 2})
        u.id = 1
        u.update_h.should eq({} of String => ::DB::Any) # no more change, because id is back to the same !
      end

      it "can save the model" do
        u = User.new({id: 1})
        u.id = 2 # Force the change!
        u.save
      end

      it "can save persisted model" do
        u = User.new({id: 1}, persisted: true)
        u.id = 2 # Force the change!
        u.save
      end

      it "can load models" do
        User.query.each do |user|
          pp user.first_name
        end
      end

      it "can read through cursor" do
        User.query.each_with_cursor(batch: 50) do |user|
          pp user.first_name
        end
      end

      it "can read json" do
        pp User.query.first!.notification_preferences
      end
    end
  end
end