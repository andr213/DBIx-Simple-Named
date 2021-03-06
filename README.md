# NAME / НАИМЕНОВАНИЕ

DBIx::Simple::Named - DBIx::Simple with named, numbered and positional 
placeholders

DBIx::Simple::Named - DBIx::Simple с именными, нумерованными и позиционными 
заполнителями

# VERSION

This documentation refers to <DBIx::Simple::Named> version 0.1.

Эта документация относится к <DBIx::Simple::Named> версии 0.1

# SYNOPSIS / ОБЗОР

Creation, configuration, database connection is realized in the super-class
[DBIx::Simple](https://metacpan.org/pod/DBIx::Simple). More details can be found in [DBIx::Simple::Examples](https://metacpan.org/pod/DBIx::Simple::Examples).

Создание, настройка, соединение с БД реализовано в супер-классе [DBIx::Simple](https://metacpan.org/pod/DBIx::Simple). 
Детальнее познакомиться с ним и посмотреть примеры использования можно в 
[DBIx::Simple::Examples](https://metacpan.org/pod/DBIx::Simple::Examples).

    use DBIx::Simple::Named;
    $db = DBIx::Simple::Named->connect(...)  # or ->new
    
    $result = $db->query(
        q{select name from cities 
            where country = :country and population > :population},
        {population=>10000, country=>'US'}
    );
    

# DESCRIPTION / ОПИСАНИЕ

DBIx::Simple::Named is a subclass of DBIx::Simple, which implements the ability 
to work with named, numbered and positional placeholders. Any of them can also 
be used as a multiple(omni) placeholder.

Модуль DBIx::Simple::Named является наследником DBIx::Simple, который реализует 
возможность работы с именованными, нумерованными и позиционными заполнителями. 
Любой из них также может использоваться в качестве множественного заполнителя. 

# EXAMPLES / ПРИМЕРЫ

#### Named placeholders / Именованные заполнители

    # sql statement / sql-запрос
    my $sql = q{select name from cities where 
            country = :country and population > :population};
            
    # using direct params binding / непосрественное связывание параметров
    $result = $db->query($sql, {country=>'US', population => 10000});
    
    # or using hash for params binding / использование хэша для связывания
    my %params = (country=>'US', population => 10000);
    $result = $db->query($sql, \%params);
    

\- binding order is not important / порядок связывания не важен

\- any placeholder may be repeated in sql-query many times / любой заполнитель 
может повторяться в sql-запросе сколько угодно раз

\- unique placeholders in the sql-query should be no less than binding
variables / уникальных заполнителей в sql-запросе должно быть не меньше чем в связываемых 
переменных

_Note. The most convenient, intuitive and scalable placeholders_

_Примечание. Наиболее удобные, наглядные и масштабируемые заполнители_

#### Numbered placeholders / Нумерованные заполнители

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
    

\- binding order is not important / порядок связывания не важен

\- any placeholder may be repeated in sql-query many times / любой заполнитель 
может повторяться в sql-запросе сколько угодно раз

#### Positional placeholders / Позиционные заполнители

    my $sql = q{select name from cities where country = ? and population > ?};
            
    # using direct params binding
    $result = $db->query($sql, ('US', 10000));
    
    # or using array for params binding
    my @params = ('US', 10000);
    $result = $db->query($sql, @params);
    

\- the number of placeholders in the query must be strictly identical to the number
bind variables / количество заполнителей в запросе должно строго совпадать с количеством 
связываемых переменных

\- the order of the placeholders must strictly match to the order of bind 
variables / порядок заполнителей должен строго соответствовать порядку 
следования связываемых переменных

#### Omni(multi) placeholders / Множественные заполнители

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
    

# METHODS

- DBIx::Simple::Named::query()

    This method overloaded from DBIx::Simple. Is responsible for executing 
    SQL statements. It is overloaded to accept any types of placeholders.

    Этот метод, перегруженный из DBIx::Simple, отвечает за выполнение SQL-запросов.
    Он перегружен для того, чтоб принимать разные типы заполнителей

# DEPENDENCIES / ЗАВИСИМОСТИ

[DBIx::Simple](https://metacpan.org/pod/DBIx::Simple), [SQL::Tokenizer](https://metacpan.org/pod/SQL::Tokenizer)

# LICENSE / ЛИЦЕНЗИЯ

Copyright (C) Andrey Yanov.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR / АВТОР

Andrey Yanov <andr213@gmail.com>

# SEE ALSO / СМ. ТАКЖЕ

[DBIx::Simple](https://metacpan.org/pod/DBIx::Simple), [SQL::Tokenizer](https://metacpan.org/pod/SQL::Tokenizer),
[DBIx::Simple::Examples](https://metacpan.org/pod/DBIx::Simple::Examples)
