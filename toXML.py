#! /usr/bin/env python

# Should bundle it all in a class:
# tags should be a member and consDic a method
tags =\
'Game.Highscore',\
'Game.avatar',\
'Game.instructions',\
'Game.flash.swf',\
'Game.flash.version',\
'Game.flash.width',\
'Game.flash.height',\
'Game.flash.params',\
'Game.flash.alternative',\
'Game.levels',\
'Game.types',\
'Game.skill',\
'Game.controltype',\
'Game.source'

def consDic(level, child):

    dic = {}

    # Let's loop trough all tags for every column (level)
    for tag in tags:

        list = tag.split('.')

        # If there are children and it is not a child we already parsed
        if [] != list[level + 1:] and child != list[level + 1]:

            # just one child
            if [] == list[level + 2:] and [] != list[level + 1:]:

                if list[level] in dic:

                    dic[list[level]].append(list[level + 1])

                else:

                    dic[list[level]] = [list[level + 1]]

            # more than one child
            elif [] != list[level + 2:]:

                if list[level] in dic:

                    dic[list[level]].append(consDic(level + 1, child))

                else:

                    dic[list[level]] = consDic(level + 1, child)

                child = list[level + 1]

    return dic

def printDic(dic):

    for key, value in dic.iteritems():

        print '<' + key + '>'

        for v in value:

            # Is the obj iterable (eg dic in our case)
            if hasattr(v, '__iter__'):

                printDic(v)

            else:

                print '<' + v + '/>'

        print '</' + key + '>'

printDic(consDic(0, ''))
