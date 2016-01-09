require_relative 'DBHandler.rb';

#version = DB::ask('select version();');
#puts version[0];

class User
	@USERTABLE = 'users';
	def self.getUserList
		return DB::ask('Select username from '+@USERTABLE);
	end
	def self.isUser? username
		sql = "Select count(user_id) from "+@USERTABLE+" where username=?";
		user = DB::seq_query(sql,[username]);
		return true if (user['count'].to_i>0);
		return false;
	end
	def self.isAdmin? username
		sql = "Select admin from "+@USERTABLE+" where username=?";
		user = DB::seq_query(sql, [username]);
		print user
	end
	def self.isActive? username
		sql = "Select active from "+@USERTABLE+" where username=?";
		user = DB::seq_query(sql, [username]);
		return user if(user === nil)
		return (user[0]['active']=='true')
	end
	def self.isBlocked? username
		sql = "Select blocked from "+@USERTABLE+" where username=?";
		user=  DB::seq_query(sql, [username]);
		puts user;
	end
	def self.isValid?(username,password)
		sql = "Select count(user_id) from "+@USERTABLE+" where active and not blocked and username=? and ssap=md5(?);";
		user = DB::seq_query(sql,[username, password]);
		return true if (user['count'].to_i>0);
		return false;
	end
	private_class_method :getUserList;
	#public :userExist?;
end

User.new;
#puts User::@USERTABLE;
#puts User.isValid? 'pedroparamo','1234';
puts User.isActive? 'pedroparamo';


