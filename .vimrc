nnoremap m <c-v>
inoremap jk <ESC>

set number
highlight LineNr ctermfg=grey
highlight Visual ctermfg=White ctermbg=LightBlue

nnoremap <c-j> :m .+1<CR>==
nnoremap <c-k> :m .-2<CR>==
inoremap <c-j> <Esc>:m .+1<CR>==gi
inoremap <c-k> <Esc>:m .-2<CR>==gi
vnoremap <c-j> :m '>+1<CR>gv=gv
vnoremap <c-k> :m '<-2<CR>gv=gv

let &t_SI = "\e[6 q"
let &t_SR = "\e[4 q"
let &t_EI = "\e[3 q"

set vb t_vb=

au FileType gitcommit setlocal tw=71

nnoremap <silent> c "_c
xnoremap <silent> c "_c
nnoremap <silent> cc "_S
nnoremap <silent> C "_C
xnoremap <silent> C "_C
nnoremap <silent> s "_s
xnoremap <silent> s "_s
nnoremap <silent> S "_S
xnoremap <silent> S "_S
nnoremap <silent> d "_d
xnoremap <silent> d "_d
nnoremap <silent> dd "_dd
nnoremap <silent> D "_D
xnoremap <silent> D "_D
nnoremap <silent> x "_x
xnoremap <silent> x "_x
nnoremap <silent> X "_X
xnoremap <silent> X "_X
vnoremap <silent> p P
