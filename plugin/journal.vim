" Filename:    journal.vim
" Description: Encrypted journal based on calendar.vim and gnupg.vim
" Maintainer:  Jeremy Cantrell <jmcantrell@gmail.com>

if exists('loaded_journal')
    finish
endif

let loaded_journal = 1

let g:journal = []

let s:save_cpo = &cpo
set cpo&vim

if !exists("g:journal_directory")
    let g:journal_directory = '~/journal'
endif

if !hasmapto('<Plug>JournalToggle')
    nmap <silent> <unique> <leader>jj <Plug>JournalToggle
endif

nnoremap <unique> <script> <Plug>JournalToggle <SID>JournalToggle
nnoremap <SID>JournalToggle :JournalToggle<cr>
command -bar JournalToggle :call s:JournalToggle()

function! s:SID() "{{{1
    return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction

function! s:JournalToggle() "{{{1
    if len(s:JournalPair(bufnr('%'))) == 2
        call s:JournalOff()
    else
        call s:JournalOn()
    endif
endfunction

function! s:JournalOn() "{{{1
    let g:calendar_action = s:SID().'JournalCalendarAction'
    let g:calendar_sign   = s:SID().'JournalCalendarSign'
    let buforig = bufnr('%')
    execute "Calendar"
    let bufcal = bufnr('%')
    call add(g:journal, [buforig, bufcal])
endfunction

function! s:JournalOff() "{{{1
    let pair = s:JournalPair(bufnr('%'))
    execute "bdelete! ".pair[1]
    unlet g:calendar_action
    unlet g:calendar_sign
    call remove(g:journal, index(g:journal, pair))
endfunction

function! s:FormatDate(year, month, day) "{{{1
    return printf('%s-%02s-%02s', a:year, a:month, a:day)
endfunction

function! s:JournalFilename(year, month, day) "{{{1
    return expand(g:journal_directory).'/'.s:FormatDate(a:year, a:month, a:day).'.asc'
endfunction

function! s:JournalCalendarAction(day, month, year, week, dir) "{{{1
    if !isdirectory(expand(g:journal_directory))
        if !s:GetConfirmation("Create journal directory '".g:journal_directory."'?")
            return
        endif
        call mkdir(expand(g:journal_directory), 'p')
    endif
    let pair = s:JournalPair(bufnr('%'))
    let filename = s:JournalFilename(a:year, a:month, a:day)
    execute bufwinnr(pair[0]).'wincmd w'
    execute 'edit '.filename
endfunction

function! s:JournalCalendarSign(day, month, year) "{{{1
    if filereadable(s:JournalFilename(a:year, a:month, a:day))
        return 1
    endif
    return 0
endfunction

function! s:GetConfirmation(prompt) "{{{1
    if confirm(a:prompt, "Yes\nNo") == 1
        return 1
    endif
    return 0
endfunction

function! s:JournalPair(buf_num) "{{{1
    for pair in g:journal
        if count(pair, a:buf_num) > 0
            return pair
        endif
    endfor
endfunction

function! s:Strip(str) "{{{1
    return substitute(substitute(a:str, '\s*$', '', 'g'), '^\s*', '', 'g')
endfunction

"}}}

let &cpo = s:save_cpo
