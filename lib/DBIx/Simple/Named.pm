package DBIx::Simple::Named;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.04";

use base qw(DBIx::Simple);
use SQL::Tokenizer qw(tokenize_sql);

sub query {
	my ($self, $query, @binds) = @_;
	
	return $self->SUPER::query(trQuery($query, @binds));
	#my $self = $self->SUPER::connect_cached(@args);
}

# transform query
sub trQuery {
	my ($sql, @binds) = @_;
	my %binds_hash;
	my @params_out;

	# превращаем массив параметров в нумерованный хэш параметров
	my $i = 0;
	if (ref($binds[0]) ne "HASH") {
		$binds_hash{++$i} = $_ for @binds;
	} else {
		# Разименовываем ссылку на хэш
		%binds_hash = %{$binds[0]};
	}

	# Раскладываем запрос на токены
	my @query_tokens = tokenize_sql($sql, 0);
	
	# Вспомогательная функция. Добавляет выходной параметр и меняет в запросе все параметры на ?
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

=head1 NAME

DBIx::Simple::Named - Module based on DBIx::Simple with Named parameters

=head1 SYNOPSIS

    use DBIx::Simple::Named;

=head1 DESCRIPTION

DBIx::Simple::Named is module based on DBIx::Simple with Named parameters

=head1 LICENSE

Copyright (C) andr213.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

andr213 E<lt>andr213@gmail.comE<gt>

=cut

