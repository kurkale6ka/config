" Open all php files
args D:\dev\cbbc\**\*.php

" phpDocumentor

" @todo {{{1
" -----
"
" function... { -> function... \n{ ?
" vim -X
" code_tidy.sh for the fully automated tasks ?
"
" see @todo further down

" Transform into real DocBlocks {{{1
" -----------------------------
"
" /** Bla */ ->
"
" /**
"  * Bla
"  */
Bgrep?/\*\*\s*\S?
let @s="0Elr\<cr>$BhC\<cr>/\<esc>:call search('/\\*\\*\\s', 'W')\<lf>"

" 2 DocBlocks at most allowed at BOF {{{1
" ----------------------------------
"
" Find any superfluous ones
" */
" /** ->
"
" *
Bgrep?\*/\_s\{-}/\*\*?

" Put braces around a phpDocumentor tag if it is not first on the line {{{1
" --------------------------------------------------------------------
"
" * @param string,  @link http://www.org.co.uk...  ->
" * @param string, {@link http://www.org.co.uk...}
" Note: only finds the 1st pattern in the line and only puts the opening {
Bgrep/^\s*\*\s\+.\{-}[^{]\%(\*\s\+\)\@<!\zs@\%(\a\+\.co\)\@!\a\+/
substitute/\%(\*\s\+\)\@<!\zs\ze@\%(\a\+\.co\)\@!\a\+/{/gc

" Find any illegal inline tag {{{1
" ---------------------------
"
" The only legal ones are:
" {@example}, {@id}, {@internal}, {@inheritdoc}, {@link}, {@source}, {@toc}, {@tutorial}
Bgrep/{\s*@\%(abstract\|access\|author\|copyright\|deprec\%(ated\)\!\|deprecated\|exception\|global\|id\|ignore\|magic\|name\|package\|param\|return\|see\|since\|static\%(var\)\!\|staticvar\|subpackage\|throws\|toc\|todo\|var\|version\)/

" Remove braces around a parameter type {{{1
" -------------------------------------
"
" {string}, {Array}... ->
"  string ,  array ...
Bgrep/\*.\{-}{\a\+}\s/
substitute/{\(\a\+\)}/\1/gc

" Remove braces if the phpDocumentor tag is the first one on the line {{{1
" -------------------------------------------------------------------
"
" * {@link https://such...} ->
" *  @link https://such...
Bgrep/^\s*\*\s\+\%({@\a\+\|@\a\+[^A-Za-z[:space:]]\)/

" Add @package Unknown for files without a @package declaration {{{1
" -------------------------------------------------------------

Bgrep/\%^\_s*<?php\%(\_.\{-}\*\s\+@package\)\@!/
let @p="ggo/**\<cr>@package Unknown\<cr>/\<esc>"

" For a url, use @link instead of @see {{{1
" ------------------------------------
"
" @see  http ->
" @link http
argdo%substitute/@\zssee\ze\s\+http/link/gce

" Add a missing @link in front of an url {{{1
" --------------------------------------
"
"        http(s)://www...  ->
" {@link http(s)://www...}
B?\*.\{-}\%(@link\s\+\)\@<!https\=://?
substitute/\(http.\{-}\)\ze\%([[:space:]]\+\|$\)/{@link \1}/gce

" @todo I Need to remove the ^ for the 3 following substitutes {{{1

" Remove trailing characters from phpDocumentor tags {{{1
" --------------------------------------------------
"
" * [@]returns ->
" * [@]return
argdo%substitute/^\s*\*\s\+@\?\%(abstract\|access\|author\|copyright\|deprec\%(ated\)\!\|deprecated\|example\|exception\|global\|ignore\|inheritdoc\|internal\|link\|magic\|name\|package\|param\|return\|see\|since\|source\|static\%(var\)\!\|staticvar\|subpackage\|throws\|todo\|tutorial\|var\|version\)\zs\a\+//gce

" Add a missing @ to phpDocumentor tags {{{1
" -------------------------------------
"
" *  return ->
" * @return
argdo%substitute/^\s*\*\s\+\zs\ze\%(abstract\|access\|author\|copyright\|deprec\|example\|exception\|global\|ignore\|inheritdoc\|internal\|link\|magic\|name\|package\|param\|return\|see\|since\|source\|static\|subpackage\|throws\|todo\|tutorial\|var\|version\)\a*\>/@/gce

" Make sure phpDocumentor tags are lowercase {{{1
" ------------------------------------------
"
" @ABSTRACT ->
" @abstract
argdo%substitute/^\s*\*\s\+@\zs\(\%(abstract\|access\|author\|copyright\|deprec\%(ated\)\!\|deprecated\|example\|exception\|global\|ignore\|inheritdoc\|internal\|link\|magic\|name\|package\|param\|return\|see\|since\|source\|static\%(var\)\!\|staticvar\|subpackage\|throws\|todo\|tutorial\|var\|version\)\a*\)/\L\1/ge
}}}1

" General

" Re-indent all files {{{1
" -------------------

argdo normal gg=G

" Remove all blank lines at EOF {{{1
" -----------------------------

argdo%substitute/\_s\+\%$//e

" Squeeze a set of blank lines into only one blank line {{{1
" -----------------------------------------------------

argdo set nofoldenable|vglobal/\S/,/\S/-j

" Remove all superfluous whitespaces {{{1
" ----------------------------------

argdo%substitute/\s\+$//e

" vim: set foldmethod=marker foldmarker&:
