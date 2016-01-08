require_relative 'DBHandler.rb';

#version = DB::ask('select version();');
#puts version[0];

class User
	@USERTABLE = 'users';
	def getUserList
		return DB::ask('Select username from '+@USERTABLE);
	end
	def self.userExist username
		sql = "Select count(*) from "+@USERTABLE+" where username=?";
		user = DB::seq_query(sql,[username]);
		return true if (user['count'].to_i>0);
		return false;
	end
	private :getUserList;
	#public :userExist?;
end

User.new;
#puts User::@USERTABLE;
puts User.userExist 'pedroparamo';


