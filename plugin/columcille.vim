
" Count the open top-level vertical split windows
fun! s:CountOpenVertical()
  " If there's only one open window, return 1
  if(winnr('$') == 1)
    return 1
  endif
  " Move to the top of the first window
  execute "1wincmd w" | execute "normal! 1G"
  " There's one window so far
  let l:count = 1 | let l:status = 0
  " Move to the next top-level vertical window
  execute "1wincmd l"
  " Add to the count each time we can move to
  " another top-level vertical window
  while winnr() != l:status
    let l:status = winnr()
    execute "1wincmd l"
    let l:count += 1
  endwhile
  " Return the total
  return l:count
endfun

" Count the open horizontal split windows in the
" current vertical split window
fun! s:CountOpenHorizontal()
  " If there aren't split windows, return 1
  if(winnr('$') == 1)
    return 1
  endif
  let l:count = 0 | let l:status = 0
  " Start by moving to the top horizontal window
  " in this vertical split window
  execute "1wincmd k"
  while winnr() != l:status
    let l:status = winnr()
    execute "1wincmd k"
  endwhile
  " Once we're there, start over, and begin the
  " count
  let l:status = 0
  " For each time we can move to another window,
  " add one to the count
  while winnr() != l:status
    let l:status = winnr()
    execute "1wincmd j"
    let l:count += 1
  endwhile
  " Return the total
  return l:count
endfun

" Set the number of open top-level vertical split
" windows
fun! s:SetColumns(count)
  let l:difference = 0
  " Save the number of the window we're in currently
  let l:original_win = winnr()
  " Get the count of open top-level vertical windows
  let l:currently_open = <SID>CountOpenVertical()
  " Move to the first window
  execute "1wincmd w "
  " From the first window, move to the last open
  " top-level vertical window
  execute l:currently_open . "wincmd l"
  " If we have fewer top-level vertical windows than
  " specified
  if l:currently_open < a:count
    " Note how many we need to open
    let l:difference = a:count - l:currently_open
    " Open that many new vertical windows
    while l:difference > 0
      execute "vs"
      let l:difference -= 1
    endwhile
  " If we have more top-level vertical windows than
  " specified
  elseif l:currently_open > a:count
    " Note how many we need to close
    let l:difference = l:currently_open - a:count
    " Close that many of the open top-level vertical
    " windows
    while l:difference > 0
      " For each vertical window we close, first
      " count its open horizontal split windows
      let l:to_close = <SID>CountOpenHorizontal()
      " Close each of those
      while l:to_close > 0
        execute "q"
        let l:to_close -= 1
      endwhile
      let l:difference -= 1
    endwhile
  endif
  " Move back to the window from which this was
  " called
  execute l:original_win . "wincmd w"
endfun

" Set the number of horizontal split windows (in
" the current top-level vertical split window, if
" there are vertical split windows open)
fun! s:SetRows(count)
  let l:difference = 0
  "
  " Save the number of the window we're in currently
  let l:original_win = winnr()
  " Get the count of horizontal split windows (in
  " this top-level vertical split window, if we're
  " in one)
  let l:currently_open = <SID>CountOpenHorizontal()
  " Move to the last (bottom) one
  execute l:currently_open . "wincmd j"
  " If we have fewer horizontal split windows here
  " than specified
  if l:currently_open < a:count
    " Note how many more we need to open
    let l:difference = a:count - l:currently_open
    " Open that many
    while l:difference > 0
      execute "sp"
      let l:difference -= 1
    endwhile
  " If we have more horizontal split windows here
  " than specified
  elseif l:currently_open > a:count
    " Note how many we need to close
    let l:difference = l:currently_open - a:count
    " Close that many
    while l:difference > 0
      execute "q"
      let l:difference -= 1
    endwhile
  endif
  " Return to the window from which this was
  " called
  execute l:original_win . "wincmd w"
endfun

" Set number of open top-level vertical split
" windows with Columns
command! -nargs=1 Columns call <SID>SetColumns(<f-args>)
" Set number of open horizontal split windows
" (in the current top-level vertical split
" window, if we're in one) with Rows
command! -nargs=1 Rows call <SID>SetRows(<f-args>)

