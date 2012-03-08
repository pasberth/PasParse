
# PasParse

## Description

パースするライブラリです

## Usage

spec を見るか、 [Rellsでの使用例](https://github.com/pasberth/Rells/blob/master/lib/bells/syntax/lexer.rb) を見てもらうのがわかりやすいかと思います


たとえば、 PasParse で `"%w[ruby lisp haskell]"` を `["ruby", "lisp", "haskell"]` にパースするなら、このように実装します:

  lexer.between('%w[', ']') do
    lexer.many do
      lang = lexer.many1(/\w/).join
      lexer.many ' '
      lang
    end
  end

expect や many 、 between といったメソッドは、トークンを「消費」します。

たとえば、

  expect "\n"
  expect "\n"

は、改行が2回続く事を意味します。

たいていの場合、これを try {} 内でおこないます。try はパースに失敗した場合、パースが始まる前の状態まで巻き戻します。

たとえば、

  try do
    expect "*"
    unexpect ' '
  end

とした場合、「'\*'から始まり、なおかつ' 'に続かない」という定義を意味します。

これは `"*ptr"` にはマッチしますが、 `* ptr` にはマッチしません。

さらに、もし`* ptr` のように、 `'\*'` にはマッチしたが、空白が続いてしまったという場合には、 try は状態を巻き戻し、nilを返します。成功した場合のみ、トークンを消費し、その文字を返します。

try を使用しない場合には、 `expect "*"` の時点で `'*'` は消費され、マッチに失敗しても巻き戻しが起こりません

また、 try は失敗した場合に nil を返すので、 or を使えば失敗した場合の定義もできます。

try はネストもできます
