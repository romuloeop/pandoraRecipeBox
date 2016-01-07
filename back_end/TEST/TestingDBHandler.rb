require_relative 'lib/DBHandler.rb'

version = DB.ask("Select version()");
puts version[0];

begin
	DB::do("Drop table foo cascade;");
	DB::do("Create table foo (id serial, something text, otro int);");
	sql = "Insert into foo (something,otro) values (?,?) returning id;";
	values = ["Lorem ipsum" , 5];
	id = DB::seq_query(sql,values);
	puts id;
	DB::commit;
rescue Exception =>e
	puts "Hubo un error: "+e.message;
	DB::rollback;
end


DB::disconnect;
