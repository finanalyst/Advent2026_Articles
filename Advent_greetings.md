
# Ringing in the changes

	Using Raku\+\+ to create website functionality


<div id="Gifts this year"></div><div id="Gifts_this_year"></div>

## Gifts this year
<span class="para" id="b038ae7"></span>Two talented Raku community members \- Andrey Shitov and Tokuhiro Matsuno \- have developed two new Raku compilers using Generative AI tools\. Andrey's [*Raku\+\+*](https://raku.online) compiles to C\+\+ and Tahiro\-san's [*mutsui*](https://tokuhirom.github.io/mutsu/) compiles to Rust\. Since there are now transpilers from C\+\+ and Rust to WASM \(a language that works inside a browser\), both compiler stacks offer a way to write Website functionality in Raku\. I consider both Raku\+\+ and mutsui to be amazing gifts to the Raku community this year, so thank you to both Andrey and Tahiro\-san\.   
<span class="para" id="a3f5002"></span>Since I ***far*** prefer writing programs in *Raku* than in *Javascript*, I was excited to try one of the above to move functionality in the new documentation website to Raku\.   
> <span class="para" id="adfb89c"></span>The new website [deployment ](https://dev.docs.raku.org) is still being tested, but both Raku\+\+ and mutsui can be invoked in the website by clicking on the Raku icon on the right\-hand side\.

  
For the purposes of this article, I can only use one of these projects, and there is a lot of documentation to read\. In addition, I have a bit more familiarity with C\+\+ than Rust, but that should not matter, but it slightly tilted my decision to use Raku\+\+ for this test\.  

<div id="Greetings in other languages"></div><div id="Greetings_in_other_languages"></div>

## Greetings in other languages
If you take a look at the new Raku documentation website, you will see a drop\-down to select the UX language\. The goal is to have Raku documentation in multiple languages, and for the UI language to be independent of the content language \(current multi\-lingual sites change both the navigation and content together which is a pain if you just want to check on some item in another language, but have to work out how to get to it in the other language\)\.  
Essentially all user\-facing text is held in HTML spans with a key, and the web page is shipped with a map from from the language / key to the text to be used\.  
What I want to explore is how much of the functionality currently implemented in Javascript can be implemented in Raku, and whether there is a performance hit\. Articles about WASM indicate that Javascript will be faster for this sort of functionality and that other language implementations in WASM will be faster for calculation heavy functionality, so this particular example should not have any performance benefit\.  

<div id="The existing implementation"></div><div id="The_existing_implementation"></div>

### The existing implementation
<span class="para" id="530d91d"></span>The following is an HTML file with a stripped down version of the Javascript\-only program \([view it here](https://htmlpreview.github.io/?https://github.com/finanalyst/Advent2026_Articles/main/greet_1.html)\)\.   

Code1.
```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
    <meta charset="UTF-8">
    <title>Greet the world</title>
    <script>
    var dictionary = { "en": { "LangName": "English", "HappyBirthday": "Happy Birthday", "Congratulations": "Congratulations", "HappyHolidays": "Happy holidays" }, "ua": { "LangName": "Українська", "HappyBirthday": "З днем ародження", "Congratulations": "Вітаю", "HappyHolidays": "Зі святами" }, "cy": { "LangName": "Cymraeg", "HappyBirthday": "Pen-blwydd hapus", "Congratulations": "Llongyfarchiadau", "HappyHolidays": "Gwyliau hapus" }, "ja": { "LangName": "日本語", "HappyBirthday": "お誕生日おめでとう", "Congratulations": "おめでとう", "HappyHolidays": "楽しい休日を" }, "nl": { "LangName": "Nederlands", "HappyBirthday": "Gefeliciteerd met je verjaardag", "Congratulations": "Gefeliciteerd", "HappyHolidays": "Fijne feestdagen" }, "epo": { "LangName": "Esperanto", "HappyBirthday": "Feliĉan naskiĝtagon", "Congratulations": "Gratulojn", "HappyHolidays": "Feliĉajn feriojn" } };
    </script>
    <script>
    function setUI( tSpans, newLang ) {
        tSpans.forEach( function (elem) {
            token = elem.getAttribute('data-UIToken');
            elem.innerHTML = dictionary[newLang][token];
        });
    };
    </script>
    <script>
        function makeUISelector( initial, selectorElem ) {
            var options = '';
            Object.keys(dictionary).forEach(function(key) {
                isSel = key == initial ? ' selected' : '';
                options = options +
                    '<option value="' + key + '"' + isSel + '>' + dictionary[key]['LangName'] + '</option>';
            });
            selectorElem.innerHTML = options;
        };
    </script>
    <script>
    var defLang = 'en';
    var uiselector;
    var token_spans;
    document.addEventListener('DOMContentLoaded', () => {
        uiselector = document.getElementById('Elucid8_ui-switch-contents');
        token_spans = document.querySelectorAll('.Elucid8-ui');
        makeUISelector( defLang, uiselector );
        setUI( token_spans, defLang );
        uiselector.addEventListener('change', (event) => {
            newLang = event.target.value;
            setUI( token_spans, newLang );
        });
    });
    </script>
</head>
<body>
<table style="border: medium groove black;">
<tr><td>Greeting language</td>
<td>Javascript: <select id="Elucid8_ui-switch-contents"></select></td></tr>
<tr><td>Greeting 1</td><td>&lt;span class="Elucid8-ui" data-uitoken="HappyBirthday">Greeting 1</span></td></tr>
    <tr><td>Greeting 2</td><td>&lt;span class="Elucid8-ui" data-uitoken="Congratulations">Greeting 2</span></td></tr>
    <tr><td>Greeting 3</td><td>&lt;span class="Elucid8-ui" data-uitoken="HappyHolidays">Greeting 3</span></td></tr>

</table>
</body>

</html>
```

<div id="Main components"></div><div id="Main_components"></div>

### Main components
<span class="para" id="d88a322"></span>The Javascript program has been split into four components between `script` tags:   
  
&nbsp;&nbsp;📜 a dictionary which contains the three greetings and language name keyed by language and token  
&nbsp;&nbsp;📜 code to generate the drop\-down selection based on the languages in the dictionary  
&nbsp;&nbsp;📜 code to replace the text of spans with the selected language  
&nbsp;&nbsp;📜 code that runs when the DOM has settled, including a search to gather into an Array all the DOM elements containing spans that have tokens that need replacing\.  

<div id="Moving into Raku?"></div><div id="Moving_into_Raku?"></div>

## Moving into Raku?
The first step is to move the dictionary to Raku \(again this is nowhere near optimal given that the dictionary is simply a native Javascript object\)\.  
<span class="para" id="6345c37"></span>Apart from the hash definition, the Raku program is trivial\. Lets assume this is the content of a text file called `r-funtions.raku`:   

Code2.
```
our %h =
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
sub rDictionary( $lang, $token ) is export {
    %h{$lang}{$token}
}
```
<span class="para" id="f6eac8b"></span>After installing the `raku++` compiler as described in [Install raku\+\+ ](https://github.com/ash/rakupp/blob/main/docs/guide/INSTALL.md), we compile this to a Javascript file called `rFunctions.js` as follows   

Code3.
```
    raku++ -o rFunctions.js --js --standalone r-functions.raku
```
Notes:  
  
&nbsp;&nbsp;📜 The `raku++` version must be > 5\.11\.0\.  
&nbsp;&nbsp;📜 The rFunctions\.js file needs to be served to the webpage, so the source used below is from a github repo via a cdn \(directly sourcing from github runs into a NoSniff error\)\.  
&nbsp;&nbsp;📜 The options for `raku++` are given in more detail in the project's dpcumentation, however  
&nbsp;&nbsp;&nbsp;&nbsp;▹ **\-o** is the output \(compiled\) file name;  
&nbsp;&nbsp;&nbsp;&nbsp;▹ **\-\-js** indicates the compilation target;  
&nbsp;&nbsp;&nbsp;&nbsp;▹ **\-\-standalone** indicates only one file is to be created; and  
&nbsp;&nbsp;&nbsp;&nbsp;▹ the final option is the input file name  
<span class="para" id="027aea2"></span>In order to link the Raku to the webpage, we add two scripts into the document `head` section, namely   

Code4.
```
<script src="http://cdn.jsdelivr.net/gh/finanalyst/Advent2026_Articles/rFunctions.js"></script>
<script>
    function rSetUI( tSpans, newLang ) {
        tSpans.forEach( function (elem) {
            token = elem.getAttribute('data-UIToken');
            elem.innerHTML = rDictionary(newLang,token);
        });
    };
</script>
```
Since the Javascript file has to be served, and the context of this blog is a bit complicated, I have loaded the file from a public github repo, which contains the RakuDoc source of this article and the raku programs\.  
<span class="para" id="92e1abc"></span>In addition, we add the following in place of the comment `// placeholder for Raku call`   

Code5.
```
ruiselector = document.getElementById('rElucid8_ui-switch-contents');
rtoken_spans = document.querySelectorAll('.r-Elucid8-ui');
makeUISelector( defLang, ruiselector );
rSetUI( rtoken_spans, defLang );
ruiselector.addEventListener('change', (event) => {
    newLang = event.target.value;
    rSetUI( rtoken_spans, newLang );
});
```

<div id="Populating DOM elements from within Raku"></div><div id="Populating_DOM_elements_from_within_Raku"></div>

### Populating DOM elements from within Raku
<span class="para" id="c117c4f"></span>In order to introspect the DOM of the HTML file, and to modify it, `raku++` has the `use js` pragma\. The pragma creates a new `JS` object, which can then be treated as *the gloabal This*\.   
<span class="para" id="1b5f8db"></span>We add the following function to our `r-functions.raku` file:   

Code6.
```
use js;
sub changeLang( $new-lang, $tag-class) is export {
	my $doc = JS.document;
	my @targets = $doc.querySelectorAll( $tag-class );
	for @targets {
		my $token = .getAttribute('data-UIToken');
		.innerHTML = %h{ $new-lang}{$token};
	}
}
```
<span class="para" id="a522e5e"></span>Then we replace the snippet in ** with   

Code7.
```
ruiselector = document.getElementById('rElucid8_ui-switch-contents');
makeUISelector( defLang, ruiselector );
changeLang( defLang, '.r-Elucid8-ui');
rSetUI( rtoken_spans, defLang );
ruiselector.addEventListener('change', (event) => {
    newLang = event.target.value;
    changeLang( newLang, '.r-Elucid8-ui');
});
```

<div id="Moving the selector creation to Raku"></div><div id="Moving_the_selector_creation_to_Raku"></div>

### Moving the selector creation to Raku
Now we take the final step by populating the language selector from the keys of the hash, and attach a listener to the selector all inside a Raku function\.



----

----

Rendered from ./Advent_greetings.rakudoc/Advent_greetings at 12:52 UTC on 2026-11-27

Source last modified at 12:39 UTC on 2026-11-27

