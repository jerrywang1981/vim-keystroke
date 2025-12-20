"======================================================================
"
" vim-keystroke -
"
" Created by Jerry Wang <jerrywang1981@outlook.com>

"
"======================================================================


"----------------------------------------------------------------------
" internal state
"----------------------------------------------------------------------
let s:last_row = -1
let s:last_col = -1

" let g:keystroke_enable = get(g:, 'keystroke_enable', 0)
let s:keystroke_enable = 0

"----------------------------------------------------------------------
" initialize
"----------------------------------------------------------------------
function! s:keystroke_init(enable)
	if a:enable == 0
		augroup KeyStrokeEvents
			au!
		augroup END
	else
		if keystroke#init() != 1
			call keystroke#errmsg('ERROR: keystroke init failed')
			return
		endif
		if exists('#TextChangedP') || exists('##TextChangedP')
			augroup KeyStrokeEvents
				au!
				au InsertEnter * call s:event_insert_enter()
				au TextChangedI * call s:event_text_changed()
				au TextChangedP * call s:event_text_changed()
			augroup END
		else
			augroup KeyStrokeEvents
				au!
				au InsertEnter * call s:event_insert_enter()
				au TextChangedI * call s:event_text_changed()
			augroup END
		endif
	endif
	let s:keystroke_enable = a:enable
endfunc

function! s:event_insert_enter()
	let s:last_row = line('.')
	let s:last_col = col('.')
endfunc

function! s:event_text_changed()
	let cur_row = line('.')
	let cur_col = col('.')
	if cur_row == s:last_row && cur_col != s:last_col
		call keystroke#play('c')
	elseif cur_row > s:last_row && cur_col <= s:last_col
		call keystroke#play("\n")
	elseif cur_row < s:last_row
		call keystroke#play("c")
	endif
	let s:last_row = cur_row
	let s:last_col = cur_col
endfunc

function! s:keystroke_toggle()
	if s:keystroke_enable != 0
		call s:keystroke_init(0)
	else
		call s:keystroke_init(1)
	endif
endfunction

"----------------------------------------------------------------------
" commands
"----------------------------------------------------------------------
command! -nargs=0 KeyStrokeEnable call s:keystroke_init(1)
command! -nargs=0 KeyStrokeDisable call s:keystroke_init(0)
command! -nargs=0 KeyStrokeToggle call s:keystroke_toggle()

