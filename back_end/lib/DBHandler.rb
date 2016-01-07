require 'rubygems'
require 'pg'
require 'dbi'

class DB
	$DBUSER = "foo";
	$DBPASS = "1234";
	@@connection = nil;
	def self.connect
		begin
			if (@@connection===nil) then
				puts "sin coneccion, conectando...";
				@@connection = DBI.connect("DBI:Pg:dbname=testdb;host=localhost", $DBUSER,$DBPASS);
			else
				puts "Conectado";
			end
		rescue Exception => e
			puts "Error al conectar con la base de datos "+e.message;
		end
	end		
	def self.ask query
		row = @@connection.select_one query;
		return row;
	end
	def self.do query 
		@@connection.do query;
		return true;
	end
	def self.disconnect
		@@connection.disconnect if @@connection
	end
	def self.commit
		@@connection.commit;
	end 
	def self.rollback
		@@connection.rollback;
	end
	def self.seq_query (query,values)
		sth = @@connection.prepare query;
		sth.execute *values;
		row = sth.fetch_hash;
		sth.finish;
		return row;
	end
end

DB.new;
DB::connect;

