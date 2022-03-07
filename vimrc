set visualbell
set vb t_vb=
set iskeyword+=:
set encoding=utf-8
set fileencodings=utf-8,iso-2022-jp,euc-jp,sjis
set mouse=a
"-------------------------------------------------------------------------
"新しい行のインデントを現在行と同じにする
"set autoindent

"タブ文字、行末など不可視文字を表示する
"set list

"listで表示される文字のフォーマットを指定する
set listchars=eol:$,tab:>\ ,extends:<

"行番号を表示する
set number

"閉じ括弧が入力されたとき、対応する括弧を表示する
set showmatch

"検索時に大文字を含んでいたら大/小を区別
set smartcase

"新しい行を作ったときに高度な自動インデントを行う
"set smartindent

"行頭の余白内で Tab を打ち込むと、'shiftwidth' の数だけインデントする
"set smarttab

"タブ入力を複数の空白入力に置き換える
set expandtab

"ファイル内の <Tab> が対応する空白の数
set tabstop=2
set softtabstop=2
set shiftwidth=2


"自動コメント防止
autocmd FileType * set formatoptions-=ro
autocmd FileType python setlocal shiftwidth=2 softtabstop=2 expandtab
autocmd FileType c setlocal shiftwidth=4 softtabstop=4
autocmd FileType cpp setlocal shiftwidth=4 softtabstop=4 
autocmd FileType cc setlocal shiftwidth=4 softtabstop=4 
"set paste

"plugin
filetype on
"filetype plugin on

"Yggdroot/indentLine
"let g:indentLine_color_term = 239

"fast re
set re=1

"拡張正規表現を利用できるよう/を/\vに置き換える
nnoremap / /\v
"cnoremap s/ s/\v
"cnoremap %s/ %s/\v

"検索結果をハイライト
set hlsearch
"Escキー2回でハイライトを消す. 
nnoremap <Esc><Esc> :noh<CR>

"色をつける
syntax on
colorscheme darkblue
"背景が明るい時
"set background=dark
"set background=light

"-------------------------------------------------------------------------
"ステータス行を表示
set laststatus=2
"
"ステータス行の指定
set statusline=%<%F\ %m%r%h%w
set statusline+=%{'['.(&fenc!=''?&fenc:&enc).']['.&fileformat.']'}
set statusline+=%=%l/%L,%c%V%8P

"%< - 行が長すぎるときに切り詰める位置
"%f - ファイル名（相対パス）
"%F - ファイル名（絶対パス）
"%t - ファイル名（パス無し)
"
"%m - 修正フラグ （[+]または[-]）
"%r - 読み込み専用フラグ（[RO]）
"%h - ヘルプバッファ
"%w - preview window flag
"
"%{'['.(&fenc!=''?&fenc:&enc).']['.&fileformat.']'} - fileencodingとfileformatを表示
"
"%= - 左寄せと右寄せ項目の区切り（続くアイテムを右寄せにする）
"%l - 現在のカーソルの行番号
"%L - 総行数
"%c - column番号
"%V - カラム番号
"%P - カーソルの場所 %表示
"Makefile用
let _curfile=expand("%:r")
if _curfile == 'Makefile'
  set noexpandtab
endif
