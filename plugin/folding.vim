if exists('vim_folding__loaded') | finish | endif | let vim_folding__loaded = 1

set fillchars+=fold:\  " BEWARE: This comment is important to keep the last space
set foldcolumn=1
set foldenable
set foldlevel=0
set foldmethod=indent
set foldnestmax=1
set foldtext=SimpleFoldText()

function GetTrimmedLine(l)
 return substitute(getline(a:l), '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

function ShouldCloseFold(l)
  let l = a:l + 1 | while getline(l) !~ '\S' | let l = l + 1 | endwhile | return (PHPFoldLevel(l) == '>1')
endfunction

function HasFunctionDeclaration(line)
  return a:line =~ '^\(public\s\+\(static\s\+\)\?\|abstract\s\+\|protected\s\+\|private\s\+\)\?function\s\+\w\+\s*('
endfunction

function PHPFoldLevel(l)
  let line = GetTrimmedLine(a:l)
  if strpart(line, 0, 2) == '*/'                                                        | return '<1' | endif
  if strpart(line, 0, 3) == '/**' || (line !~ '\}\s*$' && HasFunctionDeclaration(line)) | return '>1' | endif
  if getline(a:l) =~ '^\S' || (strpart(line, 0, 2) == '}' && ShouldCloseFold(a:l))      | return '<1' | endif
                                                                                          return '='
endfunction

function PHPFoldSummary()
  let line = GetTrimmedLine(v:foldstart) | let indent = repeat(' ', strlen(getline(v:foldstart)) - strlen(line))

  if strpart(line, 0, 3) == '/**'
    let nextLine = GetTrimmedLine(v:foldstart + 1)
    if v:foldend - v:foldstart == 2 | return indent . substitute(nextLine, "^\\**", "//", "") | endif
    return indent .'//'. strpart(nextLine, 1) .' (...)'
  elseif HasFunctionDeclaration(line) | return indent . line . SimpleFoldText() .' }' | endif

  return SimpleFoldText()
endfunction

function SimpleFoldText()
  let lines = v:foldend - v:foldstart + 1 | return '  ... [ '. lines .' lines ] ...'
endfunction

