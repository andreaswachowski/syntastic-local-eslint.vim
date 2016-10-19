let s:lcd = fnameescape(getcwd())
silent! exec "lcd" expand('%:p:h')

" npm bin would yield something like "<project-dir>/node_modules/.bin"
" Therefore, use <project-dir> as key to cache the eslint-path,
" and use that path when the current file has that prefix.
if !exists("g:syntastic_local_eslint_npm_bin_cache")
  let g:syntastic_local_eslint_npm_bin_cache={}
endif
let s:cwd = fnameescape(getcwd())
for key in keys(g:syntastic_local_eslint_npm_bin_cache)
  if match(s:cwd,key)
    let s:eslint_path = g:syntastic_local_eslint_npm_bin_cache[key]
    break
  endif
endfor
if !exists('s:eslint_path')
  let s:eslint_path = system('PATH=$(npm bin):$PATH && which eslint')
  if fnamemodify(s:eslint_path, ':h:h:t') == 'node_modules' " local eslint
    let s:project_dir = fnamemodify(s:eslint_path, ':h:h:h')
    let g:syntastic_local_eslint_npm_bin_cache[s:project_dir] = s:eslint_path
  endif
endif
exec "lcd" s:lcd
let b:syntastic_javascript_eslint_exec = substitute(s:eslint_path, '^\n*\s*\(.\{-}\)\n*\s*$', '\1', '')
