all:
	gcc -Wall -g -o diary diary.c \
	`pkg-config --cflags --libs gtk+-2.0` \
	`pkg-config --cflags --libs glib-2.0` \
	`xml2-config --cflags --libs` \
	`pkg-config --cflags --libs libglade-2.0`

