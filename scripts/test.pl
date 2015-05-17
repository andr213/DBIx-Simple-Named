#!/usr/bin/perl

use 5.10.0;


#use DBIx::Simple;
use Data::Dumper;
#use Try::Tiny;
#use SimpleX;
#use utf8;

#my $test = Placeholders->new();
#say $test->prepare('select id, name from dict where id1 = ? and id2 = ? and id3 = ?');
#say $test->prepare('select id, name from dict where id1 = $2 and id2 = $1 and id3 in ($3)');
#$test->prepare('select id, name from dict where id1 = :p2 id2 = :p1 and id2 = :p2 and id3 in (:p3)');
#$test->binds({p1=>1, p2=>2, p3=>[3,4,5]});
#say Dumper(trQuery("select id, name from dict where id1 = ? and id2 = ? and id3 = ?", 1, 2, 3));
#say Dumper trQuery('select id, name from dict where id1 = $1 and id2 = $2 and id3 in ($3)', 1, 2, [3,4,5]);
#say Dumper(trQuery('select id, name from dict where id1 = :p1 id2 = :p1 and id2 = :p2 and id3 in (:p3)', {p1=>1, p2=>2, p3=>[3,4,5]}));

#use Object::Accessor;
#use DBIx::Simple;
#my $db = DBIx::Simple->connect(
#	'dbi:Pg:dbname=aDB',     # DBI source specification
#	'aUser', 'he3yhxha',                # Username and password
#	{ RaiseError => 1 }            # Additional options
#);
#say $db->query(q{select 2 as id, 'name1' as name, 'dop1' as dop where 2 = ? union all select 3 as id, 'name2' as name, 'dop2' as dop}, 1)->objects->[0]->name;
#say Dumper($test);

#use DBI::Lite;
#my $db = DBI::Lite->connect(
#	'dbi:Pg:dbname=aDB',
#	'aUser',
#	'he3yhxha',
#	{ RaiseError => 0, PrintError => 0 }
#) or die "Error connecting to database";

#say $db->query(q{select 2 as id, 'name1' as name, 'dop1' as dop where 2 = $2 union all select 3 as id, 'name2' as name, 'dop2' as dop}, 1,2)->rows();
#say Dumper(@test);


#my $test = $db->query(q{select 2 as id, 'name1' as name, 'dop1' as dop where 2 = $2 union all select 3 as id, 'name2' as name, 'dop2' as dop}, 1,2)->object->name;
#say Dumper($test);

use DBI::Lite;
my $db = DBI::Lite->connect(
	'dbi:Pg:dbname=aDB',     # DBI source specification
	'aUser', 'he3yhxha',                # Username and password
	{ RaiseError => 1 }            # Additional options
) or die "Error connecting to database";
my $res = $db->query(q{
	select 2 as id, 'name1' as name, 'dop1' as dop where 1 = ? 
	union all 
	select 3 as id, 'name2' as name, 'dop2' as dop 
	union all 
	select 4 as id, 'name4' as name, 'dop4' as dop 
}, 1);
#while ($res->into(my (@arr))){
#	say "name = $name"
#}
#$res->into(my (@arr));
#say "name = ". $arr[0];
#my $r = $res->;
#say Dumper($r);
#say 'cols='.$res->cols;

#say Dumper($db->query("select 1 as id,'test' as name where 1 in (:id)", {id=>[1,2,3]})->map_hashes('id'));

#use DBI::OResult;
#my $db = DBI::OResult->connect(
#	'dbi:Pg:dbname=aDB',     # DBI source specification
#	'aUser', 'he3yhxha',                # Username and password
#	{ RaiseError => 1 }            # Additional options
#);
#my $sth = $db->prepare(q{
#	select 2 as id, 'name1' as name, 'dop1' as dop where 1 = ? 
#	union all 
#	select 3 as id, 'name2' as name, 'dop2' as dop 
#	union all 
#	select 4 as id, 'name4' as name, 'dop4' as dop 
#
#});
#say Dumper $sth;
#my $res = $sth->execute(1);
#my $arr = $sth->name2->[0];
#say Dumper ($arr);

