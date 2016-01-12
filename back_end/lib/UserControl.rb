require_relative 'DBHandler.rb';

#version = DB::ask('select version();');
#puts version[0];
require 'securerandom'
require 'net/smtp'
#require 'tlsmail'
class User
	@USERTABLE = 'users';
	@mailDomain = 'gmail.com';
	@mailSMTP = 'smtp.gmail.com';
	@mailPort = 587;
	@mailUser = '';
	@mailPass = '';
	
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
		return user if(user === nil);
		return (user[0]['admin']=='true');
	end
	def self.isActive? username
		sql = "Select active from "+@USERTABLE+" where username=?";
		user = DB::seq_query(sql, [username]);
		return user if(user === nil);
		return (user[0]['active']=='true');
	end
	def self.isBlocked? username
		sql = "Select blocked from "+@USERTABLE+" where username=?";
		user=  DB::seq_query(sql, [username]);
		return user if(user === nil);
		return (user[0]['blocked']=='true');
	end
	def self.isValid?(username,password)
		sql = "Select count(user_id) from "+@USERTABLE+" where active and not blocked and username=? and ssap=md5(?);";
		user = DB::seq_query(sql,[username, password]);
		return true if (user['count'].to_i>0);
		return false;
	end
	def self.getUserByUsername username
	 		sql = "Select user_id,username,mail,created_on from "+@USERTABLE+" where username=?;";
		  user = DB::seq_query(sql,[username]);
		  return user;
	end
	def self.getUserByMail mail
	 	sql = "Select user_id,username,mail,created_on from "+@USERTABLE+" where mail=?;";
		 user = DB::seq_query(sql,[mail]);
		 return user;
	end
	def self.blockUser(username,blocker,block=true)
		sql = "Update "+@USERTABLE+" set blocked=?, blocked_on=now(),
			blocked_by=? where username=?;";
		begin;
			DB::seq_query(sql,[block,blocker, username]);
			DB::commit();
			return true;
		rescue Exception => e
			DB::rollback();
			return false;
		end;
	end
	def self.createUser userData
		#puts userData;
		return false if self::isUser? userData[:username];
		return false if ((self::getUserByMail(userData[:mail])) != nil);
		sql = "Insert into "+@USERTABLE+" 
			(username, nombre, ssap, sec_question, sec_answer,
			activation_code, mail) values (?,?,md5(?),?,md5(?),?,?);
		";
		uuid = SecureRandom.uuid.split('-').last;
		data = [userData[:username], userData[:name], userData[:ssap], 
			userData[:question], userData[:answer], uuid, userData[:mail]
			];
		begin;
			message = <<MESSAGE_END
From: Register System <#{@mailUser}@#{@mailDomain}>
To: #{userData[:name]} <#{userData[:mail]}>
Subject: User activation

Thanks for sign in, to complete your register enter
the next code #{uuid}
MESSAGE_END
			smtp = Net::SMTP.new(@mailSMTP,@mailPort);
			smtp.enable_starttls
			smtp.start(@mailDomain,@mailUser,@mailPass, :plain) do |smtp|
				smtp.tls?
				smtp.sendmail(message,@mailUser+'@'+@mailDomain,[userData[:mail]]);
			end
			DB::seq_query(sql,data);
			DB::commit;
			return true;
		rescue Exception => e
			puts e.message+"\n";
			p e.backtrace;
			DB::rollback;
			return false;
		end;

	end

	
	private_class_method :getUserList;
	#public :userExist?;
end

User.new;
#puts User::@USERTABLE;
#puts User.isValid? 'pedroparamo','1234';

puts (User.isActive? 'pedroparamo')=== nil;

newuser = {
	:username=>"jhon.doe",
	:name=>"Jhon Doe",
	:ssap=>"1234",
	:question=>"Favorite movie",
	:answer=>"Addams Family",
	:mail=>"chavo45@hotmail.com"
};

User::createUser newuser
