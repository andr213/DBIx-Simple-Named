package DBIx::Simple::Named;
use strict;
use warnings;
our $VERSION = "0.01";

use base qw(DBIx::Simple);
use SQL::Tokenizer qw(tokenize_sql);

sub query {
	my ($self, $query, @binds) = @_;
	
	return $self->SUPER::query(_prepareQuery($query, @binds));
}

# transform query
sub _prepareQuery {
	my ($sql, @binds) = @_;
	my %binds_hash; # хэш параметров
	my @params_out; #Массив выходных параметров

	
	my $i = 0;
	if (ref($binds[0]) ne "HASH") {
		$binds_hash{++$i} = $_ for @binds;# превращаем массив параметров в нумерованный хэш параметров
	} else {
		%binds_hash = %{$binds[0]};# Разименовываем ссылку на хэш, создавая  хэш параметров
	}

	# Раскладываем запрос на токены
	my @query_tokens = tokenize_sql($sql, 0);
	
	# Вспомогательная функция. 
	# Все placeholder-ы заменяет позиционными ?. 
	# Добавляет параметр в выходной массив параметров
	# Если подразумевается использование multi placeholder, то вставляет необходимое количество ?
	my $testSub = sub {
		my ($placeholder_name, $index) = @_;
		
		if (ref($binds_hash{$index}) eq 'ARRAY') {
			$placeholder_name = '';
			$placeholder_name .= '?,' for @{$binds_hash{$index}};
			chop($placeholder_name);
			push @params_out, $_ for @{$binds_hash{$index}};
		} else {
			$placeholder_name = '?';
			push @params_out, $binds_hash{$index};
		}
		return $placeholder_name;
	};

	# Вспомогательная переменная для подсчета индекса позиционнного параметра в цикле foreach
	my $params = 0;

	# Цикл, кот перебирает все placeholders в запросе, меняет их на ? и записывает значения в выходной массив параметров
	foreach my $token (@query_tokens) {
		# Позиционные параметры
		if ($token eq '?') {
			$params++;
			$token = $testSub->($token, $params);
		} else { 
			# Нумерованные параметры
			if ($token =~ /^\$(\d+)$/) {
				$token = $testSub->($token, $1);
			} else {
				# Именные параметры
				if ($token =~ /^\:(\w+)$/) {
					$token = $testSub->($token, $1);
				}
			}
		}
	}

	# Собираем запрос из токенов
	$sql = join '', @query_tokens;
	return ($sql, @params_out);
}

1;
__END__

=encoding utf-8

=head1 NAME / НАИМЕНОВАНИЕ

DBIx::Simple::Named - DBIx::Simple with named, numbered and positional 
placeholders

DBIx::Simple::Named - DBIx::Simple с именными, нумерованными и позиционными 
заполнителями

=head1 VERSION

This documentation refers to <DBIx::Simple::Named> version 0.1.

Эта документация относится к <DBIx::Simple::Named> версии 0.1


=head1 SYNOPSIS / ОБЗОР

Creation, configuration, database connection is realized in the super-class
L<DBIx::Simple>. More details can be found in L<DBIx::Simple::Examples>.
    
Создание, настройка, соединение с БД реализовано в супер-классе L<DBIx::Simple>. 
Детальнее познакомиться с ним и посмотреть примеры использования можно в 
L<DBIx::Simple::Examples>.

    use DBIx::Simple::Named;
    $db = DBIx::Simple::Named->connect(...)  # or ->new
    
    $result = $db->query(
        q{select name from cities 
            where country = :country and population > :population},
        {population=>10000, country=>'US'}
    );
    
=head1 DESCRIPTION / ОПИСАНИЕ

DBIx::Simple::Named is a subclass of DBIx::Simple, which implements the ability 
to work with named, numbered and positional placeholders. Any of them can also 
be used as a multiple(omni) placeholder.

Модуль DBIx::Simple::Named является наследником DBIx::Simple, который реализует 
возможность работы с именованными, нумерованными и позиционными заполнителями. 
Любой из них также может использоваться в качестве множественного заполнителя. 

=head1 EXAMPLES / ПРИМЕРЫ

=head4 Named placeholders / Именованные заполнители

    # sql statement / sql-запрос
    my $sql = q{select name from cities where 
            country = :country and population > :population};
            
    # using direct params binding / непосрественное связывание параметров
    $result = $db->query($sql, {country=>'US', population => 10000});
    
    # or using hash for params binding / использование хэша для связывания
    my %params = (country=>'US', population => 10000);
    $result = $db->query($sql, \%params);
    
- binding order is not important / порядок связывания не важен

- any placeholder may be repeated in sql-query many times / любой заполнитель 
может повторяться в sql-запросе сколько угодно раз

- unique placeholders in the sql-query should be no less than binding
variables / уникальных заполнителей в sql-запросе должно быть не меньше чем в связываемых 
переменных

I<Note. The most convenient, intuitive and scalable placeholders>

I<Примечание. Наиболее удобные, наглядные и масштабируемые заполнители>

=head4 Numbered placeholders / Нумерованные заполнители

    # sql statement / sql-запрос
    my $sql = q{select name from cities where 
            country = $1 and population > $2};

    # using direct params binding / непосрественное связывание параметров
    $result = $db->query($sql, ('US', 10000));
    
    # or using array for params binding / или использование массива для связывания
    my @params = ('US', 10000);
    $result = $db->query($sql, @params);
    
    # or using hash for params binding / использование хэша для связывания
    my %params = (1=>'US', 2=>10000);
    $result = $db->query($sql, \%params);
    
- binding order is not important / порядок связывания не важен
    
- any placeholder may be repeated in sql-query many times / любой заполнитель 
может повторяться в sql-запросе сколько угодно раз

=head4 Positional placeholders / Позиционные заполнители

    my $sql = q{select name from cities where country = ? and population > ?};
            
    # using direct params binding
    $result = $db->query($sql, ('US', 10000));
    
    # or using array for params binding
    my @params = ('US', 10000);
    $result = $db->query($sql, @params);
    
- the number of placeholders in the query must be strictly identical to the number
bind variables / количество заполнителей в запросе должно строго совпадать с количеством 
связываемых переменных

- the order of the placeholders must strictly match to the order of bind 
variables / порядок заполнителей должен строго соответствовать порядку 
следования связываемых переменных
    
=head4 Omni(multi) placeholders / Множественные заполнители

any of the three types of placeholders can be used as a omni(multiple) 
placeholders. They are used in cases when the number of placeholders is not 
known beforehand. For example, within the operator IN.

любой из трех типов заполнителей может использоваться в качестве множественного 
заполнителя. Используются они в тех случаях, когда заранее неизвестно их 
количество. Например, внутри оператора IN.
    
    my $sql = q{select name from cities where country in (:country)};
    $result = $db->query($sql, {country=>['US', 'UA']});
    
    # or
    
    my $sql = q{select name from cities where country in ($1)};
    $result = $db->query($sql, (['US', 'UA']);
    
    # or
    
    my $sql = q{select name from cities where country in (?)};
    $result = $db->query($sql, (['US', 'UA']);
    
They are very convenient to use in the INSERT, for example / Их очень удобно 
использовать в операторах INSERT, например:

    # insert using named placeholders / insert с помощью именных заполнителей
    my $sql = q{insert into cities (name, country, population) 
        values (:name, :country, :population)};
    $result = $db->query($sql, {name=>'NY', country=>'US', population=>10000});
    
    # or insert using omni named placeholders / insert с помощью omni(multi) заполнителей
    my $sql = q{insert into cities (name, country, population) 
        values (:cities)};
    $result = $db->query($sql, {cities=>['NY','US', 10000]});
    

=head1 METHODS

=over 4

=item DBIx::Simple::Named::query()

This method overloaded from DBIx::Simple. Is responsible for executing 
SQL statements. It is overloaded to accept any types of placeholders.

Этот метод, перегруженный из DBIx::Simple, отвечает за выполнение SQL-запросов.
Он перегружен для того, чтоб принимать разные типы заполнителей

=back

=cut

=head1 DEPENDENCIES / ЗАВИСИМОСТИ

L<DBIx::Simple>, L<SQL::Tokenizer>

=head1 LICENSE / ЛИЦЕНЗИЯ

Copyright (C) Andrey Yanov.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR / АВТОР

Andrey Yanov E<lt>andr213@gmail.comE<gt>

=head1 SEE ALSO / СМ. ТАКЖЕ

L<DBIx::Simple>, L<SQL::Tokenizer>,
L<DBIx::Simple::Examples>

=cut

