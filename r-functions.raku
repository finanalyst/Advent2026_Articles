our %h =
		en => %(
			LangName => "English",
			HappyBirthday => "Happy Birthday",
			Congratulations => "Congratulations",
			HappyHolidays => "Happy holidays",
		),
		uk => %(
			LangName => "Українська",
			HappyBirthday => "З днем народження",
			Congratulations => "Вітаю",
			HappyHolidays => "Зі святами",
		),
		cy => %(
			LangName => "Cymraeg",
			HappyBirthday => "Pen-blwydd hapus",
			Congratulations => "Llongyfarchiadau",
			HappyHolidays => "Gwyliau hapus",
		),
		ja => %(
			LangName => "日本語",
			HappyBirthday => "お誕生日おめでとう",
			Congratulations => "おめでとう",
			HappyHolidays => "楽しい休日を",
		),
		nl => %(
			LangName => "Nederlands",
			HappyBirthday => "Gefeliciteerd met je verjaardag",
			Congratulations => "Gefeliciteerd",
			HappyHolidays => "Fijne feestdagen",
		),
		epo => %(
			LangName => "Esperanto",
			HappyBirthday => "Feliĉan naskiĝtagon",
			Congratulations => "Gratulojn",
			HappyHolidays => "Feliĉajn feriojn",
		),
	;
sub rDictionary( $lang, $token ) is export {
    %h{$lang}{$token}
}
use js;
sub changeLang( $new-lang, $tag-class) is export {
	my $doc = JS.document;
	my @targets = $doc.querySelectorAll( $tag-class ).list;
	for @targets -> $elem {
		my $token = $elem.getAttribute('data-UIToken');
		$elem<innerHTML> = %h{$new-lang}{$token};
	}
}
sub setSelector( $selectorElem, $tag-class, $initial ) is export {
	my $doc = JS.document;
	my $sel = $doc.getElementById( $selectorElem );
	my $options = [~] %h.map({
		'<option value="' ~ .key ~ '"' ~ { .key eq $initial ?? ' selected' !! ''} ~ '>' ~ .value<LangName> ~ '</option>'
	});
	$sel<innerHTML> = $options;
	changeLang( $initial, $tag-class );
	# set up Event listener on selector
	$sel.addEventListener('change', -> $el {
		my $new-language = $el.target.value;
		changeLang( $new-language, $tag-class );
	});
}
