#include <gtk/gtk.h>
#include <glade/glade.h>


int main(int argc, char *argv[])
{
    GtkWidget *window;
    GladeXML *xml;

    gtk_init(&argc, &argv);

    xml = glade_xml_new("diary.glade", NULL, NULL);
    window = glade_xml_get_widget(xml, "window1");

    glade_xml_signal_autoconnect(xml);

    gtk_widget_show_all(window);
    gtk_main();

    return 0;
}


