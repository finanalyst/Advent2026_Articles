sub rDictionary( $lang, $token ) is export {
    my %h =
            en => %(
                LangName => "English",
                HappyBirthday => "Happy Birthday",
                Congratulations => "Congratulations",
                HappyHolidays => "Happy holidays",
            ),
            ua => %(
                LangName => "Українська",
                HappyBirthday => "З днем ародження",
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
    %h{$lang}{$token}
}
