"======================================================================
"
" vim-keystroke -
"
" Created by Jerry Wang <jerrywang1981@outlook.com>
"
"======================================================================


"----------------------------------------------------------------------
" global settings
"----------------------------------------------------------------------

let g:keystroke_theme = get(g:, 'keystroke_theme', 'default')
let s:default_players = {
      \ 'play': 'play',
      \ 'aplay': 'aplay',
      \ 'mpg123': 'mpg123',
      \ 'mpg321': 'mpg321',
      \ 'paplay': 'paplay',
      \ 'cvls': 'cvls --play-and-exit',
      \ 'afplay': 'afplay'
      \ }

let g:keystroke_players = get(g:, 'keystroke_players', {})

let s:plugindir = expand('<sfile>:p:h:h')

"----------------------------------------------------------------------
" tools
"----------------------------------------------------------------------
function! keystroke#errmsg(msg)
	redraw | echo '' | redraw
	echohl ErrorMsg
	echom a:msg
	echohl NONE
endfunc

"----------------------------------------------------------------------
" local init
"----------------------------------------------------------------------

let s:keystroke_inited = 0
let s:keystroke_sound_supported = 0 " if this plugin is supported or not
let s:has_sound_support = get(g:, 'keystroke_vim_sound', has('sound'))
let s:has_job_support = has('job')
let s:theme_list = ['default', 'bubble', 'mario', 'sword', 'typewriter']
let s:themes = {}
let s:sound_files = {}

if !exists('s:env')
  if has('win64') || has('win32') || has('win16')
    let s:env = 'WINDOWS'
  else
    let s:env = toupper(substitute(system('uname'), '\n', '', ''))
  endif
endif

"----------------------------------------------------------------------
" init import
"----------------------------------------------------------------------
function! s:init()
  if s:keystroke_inited == 1
    return 1
  endif

  call s:init_theme_dict()
  call extend(g:keystroke_players, s:default_players, 'keep')
  call s:init_sound_files()

  if s:keystroke_sound_supported == 0
		call keystroke#errmsg('ERROR: not find binary to play wav file, make sure one of play/aplay is installed ')
    return 0
  endif
  let s:keystroke_inited = 1
  return 1
endfunc


"----------------------------------------------------------------------
" play a sound
"----------------------------------------------------------------------
let s:play_sound_jobs = []

function! keystroke#playsound(filename)
  let l:filename = s:sound_files[g:keystroke_theme][a:filename]

  if s:has_sound_support == 1
    call sound_playfile(l:filename)
  elseif s:has_job_support == 1
    call add(s:play_sound_jobs, job_start(l:filename))
    if len(s:play_sound_jobs) > 10
      let s:play_sound_jobs = s:play_sound_jobs[-5:]
    endif
  else
    call system(l:filename)
  endif
endfunc


"----------------------------------------------------------------------
" choose_theme
"----------------------------------------------------------------------
function! s:choose_theme(theme)
  let l:path = fnamemodify(fnamemodify(s:plugindir, ':p') .. 'sounds', ':p') .. a:theme
  if isdirectory(l:path)
    return l:path
  else
		call keystroke#errmsg('ERROR: not find "'. a:theme.'" in "'. s:plugindir .'"')
    return ''
  endif
endfunc

function! s:init_theme_dict()
  for t in s:theme_list
    if !has_key(s:themes, t)
      let s:themes[t] = s:choose_theme(t)
    endif
  endfor
endfunction

function! s:init_sound_files()
  let l:keys = ['default.wav', 'enter.wav']
  for t in s:theme_list
    let s:sound_files[t] = {}

    if s:has_sound_support == 1
      let s:keystroke_sound_supported = 1
      for k in l:keys
        let s:sound_files[t][k] = fnamemodify(s:themes[t], ':p') .. k
      endfor
    elseif s:env == 'WINDOWS'
      let s:keystroke_sound_supported = 0
      " let s:keystroke_sound_supported = 1
      " let l:cmd = fnamemodify(fnamemodify(s:plugindir, ':p') .. 'sounds', ':p') .. 'cmdmp3.exe'
      " for k in l:keys
      "   let l:sound_file = fnamemodify(s:themes[t], ':p') .. k
      "   let s:sound_files[t][k] = l:cmd .. ' ' .. l:sound_file
      " endfor
    else
      for b in keys(g:keystroke_players)
        if executable(b)
          let s:keystroke_sound_supported = 1
          for k in l:keys
            let l:sound_file = fnamemodify(s:themes[t], ':p') .. k
            let s:sound_files[t][k] = get(g:keystroke_players, b) .. ' ' .. l:sound_file
          endfor
          break
        endif
      endfor
    endif

  endfor
endfunction


function! keystroke#init() abort
	if s:init() == 0
		return 0
	endif
	return 1
endfunc

function! keystroke#play(key)
	if a:key == "\n"
    call keystroke#playsound('enter.wav')
	else
    call keystroke#playsound('default.wav')
	endif
endfunc

function! keystroke#print_all()
  echom "g:keystroke_theme: " . g:keystroke_theme
  echom "themes: "
  echom  s:themes
  echom "keystroke_players"
  echom g:keystroke_players
  echom "default_players: "
  echom s:default_players
  echom "keystroke initiated? " . s:keystroke_inited
  echom "sound support? " . s:keystroke_sound_supported
  echom "sound files: "
  echom s:sound_files
endfunction
