#include <gtk/gtk.h>
#include <glade/glade.h>
#include <glib.h>
#include <stdio.h>
#include <libxml/xmlreader.h>
#include <assert.h>


GHashTable *diaryData;


typedef enum {
    STATE_NONE,
    STATE_ITEM
} parsingStatus;



/**
 * 現在XMLReaderがポイントしている場所の
 * XMLノード1つを処理する
 */
void processNode(xmlTextReaderPtr reader)
{
    static parsingStatus state = STATE_NONE;
    static xmlChar *date;
    xmlElementType nodeType;
    xmlChar *name, *value;

    nodeType = xmlTextReaderNodeType(reader);
    
    if (nodeType == XML_READER_TYPE_ELEMENT) {              //  開始タグ
        name = xmlTextReaderName(reader);
        if ( xmlStrcmp(name, BAD_CAST "diary") == 0 ) {
            //  do nothing

        } else if ( xmlStrcmp(name, BAD_CAST "item") == 0 ) {
            state = STATE_ITEM;

            //  <item>タグの中には、日記の日付を表す date="yyyymmdd" という属性が
            //  設定されているはずなので、これを探す。
            date = xmlTextReaderGetAttribute(reader, BAD_CAST "date");
            if (!date) {
                fprintf(stderr, "Invalid format (attribute 'date' not found)\n");
                exit(-1);
            }

        } else {
            fprintf(stderr, "Invalid data [%s]\n", name);
            exit(-1);
        }     

        xmlFree(name);

    } else if (nodeType == XML_READER_TYPE_END_ELEMENT) {   //  終了タグ
        state = STATE_NONE;
    
    } else if (nodeType == XML_READER_TYPE_TEXT) {          //  テキスト
        assert(state == STATE_ITEM);

        value = xmlTextReaderValue(reader);
        if (!value) {
            fprintf(stderr, "Invalid format (content not found)\n");
            exit(-1);
        }

        //  日付 => 本文 の形式でハッシュに登録する
        g_hash_table_insert(diaryData, (gpointer)date, value);
    } 
        
}



/**
 * 日記データをXMLファイルより読み込む
 */
void diaryDataInit()
{
    diaryData = g_hash_table_new(g_str_hash, g_str_equal);

    xmlTextReaderPtr reader;
    int ret;
    
    reader = xmlNewTextReaderFilename("./diary.xml");
    assert(reader);

    ret = xmlTextReaderRead(reader);

    while (ret == 1) {
        processNode(reader);
        ret = xmlTextReaderRead(reader);
    }

    xmlFreeTextReader(reader);
}


/**
 * カレンダー上の日付が選択されたときにコールされる
 * コールバック関数。
 * その日付の日記本文を読み込んで、右側のテキストエリアに
 * 表示する
 */
void calendar_day_selected(GtkCalendar *calendar, GtkTextView *textarea) 
{
    guint year, month, day;
    gchar date[9];
    gpointer content;
    GtkTextBuffer *buffer = gtk_text_view_get_buffer(textarea);

    //  日付文字列(yyyymmdd)の作成
    gtk_calendar_get_date(calendar, &year, &month, &day);
    month++;
    snprintf(date, 9,"%04d%02d%02d", year, month, day);
    
    content = g_hash_table_lookup(diaryData, date);
    if (content) {
        gtk_text_buffer_set_text(buffer, content, -1);
    }
    else {
        //  その日付の日記が未登録である場合は
        //  日記本文＝空文字列とみなす
        gtk_text_buffer_set_text(buffer, "", -1);
    }
    
}


/**
 * main
 */
int main(int argc, char *argv[])
{
    GtkWidget *window;
    GtkWidget *calendar;
    GtkWidget *textarea;
    GladeXML *xml;

    diaryDataInit();

    gtk_init(&argc, &argv);

    xml = glade_xml_new("diary.glade", NULL, NULL);
    window = glade_xml_get_widget(xml, "window1");
    calendar = glade_xml_get_widget(xml, "calendar");
    assert(calendar);

    textarea = glade_xml_get_widget(xml, "content");
    assert(textarea);

    glade_xml_signal_autoconnect(xml);

    g_signal_connect(G_OBJECT(calendar), "day-selected",
                            G_CALLBACK(calendar_day_selected), (gpointer)textarea);

    gtk_widget_show_all(window);
    gtk_main();

    g_hash_table_destroy(diaryData);

    return 0;
}


