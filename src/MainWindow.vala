/*
* Copyright (c) 2017 Lains
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/
using Soup;
using Json;

namespace Coin {
    public class MainWindow : Gtk.Dialog {
        public Gtk.Label label_result;
        public Gtk.Label label_info;

        public double avg;
        public string time;

        public MainWindow (Gtk.Application application) {
            GLib.Object (application: application,
                    icon_name: "com.github.lainsce.coin",
                    resizable: false,
                    title: _("Coin"),
                    height_request: 272,
                    width_request: 500
            );

            Granite.Widgets.Utils.set_theming_for_screen (
                this.get_screen (),
                Stylesheet.BODY,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            );
        }

        construct {
            set_keep_below (true);
            stick ();

            this.get_style_context ().add_class ("rounded");
            this.window_position = Gtk.WindowPosition.CENTER;

            get_values();
            make_ui ();
            Timeout.add_seconds (3600, get_values);

            var settings = AppSettings.get_default ();

            int x = settings.window_x;
            int y = settings.window_y;

            if (x != -1 && y != -1) {
                move (x, y);
            }
        }

        public override bool delete_event (Gdk.EventAny event) {
            int x, y;
            get_position (out x, out y);

            var settings = AppSettings.get_default ();
            settings.window_x = x;
            settings.window_y = y;

            return false;
        }

        public void make_ui () {
            var icon = new Gtk.Image.from_icon_name ("com.github.lainsce.coin-symbolic", Gtk.IconSize.DIALOG);

            label_result = new Gtk.Label ("");
            label_info = new Gtk.Label ("");
            label_result.set_markup ("""<span font="36">$%.2f</span><span font="14">/1 BTC</span>""".printf(avg));
            label_info.set_markup ("""<span font="10">Updated on: %s</span>""".printf(time));
            label_info.set_halign (Gtk.Align.END);

            var grid = new Gtk.Grid ();
            grid.column_spacing = 12;
            grid.margin_bottom = 6;
            grid.margin_end = 18;
            grid.margin_start = 18;
            grid.attach (icon, 0, 0, 1, 1);
            grid.attach (label_result, 2, 0, 1, 1);
            grid.attach (label_info, 2, 1, 1, 1);

            var stack = new Gtk.Stack ();
            stack.transition_type = Gtk.StackTransitionType.CROSSFADE;
            stack.vhomogeneous = true;
            stack.add_named (grid, "money");

            var content_box = get_content_area () as Gtk.Box;
            content_box.border_width = 0;
            content_box.add (stack);
            content_box.show_all ();
        }

        public bool get_values () {
            var uri = "https://btc-e.com/api/2/btc_usd/ticker";
            var session = new Soup.Session ();
            var message = new Soup.Message ("GET", uri);
            session.send_message (message);

            try {
                var parser = new Json.Parser ();
                parser.load_from_data ((string) message.response_body.flatten ().data, -1);
                var root_object = parser.get_root ().get_object();
                var response = root_object.get_object_member ("ticker");
                avg = response.get_double_member("avg");
                var timestamp = response.get_int_member("updated");
                var datetime = new DateTime.from_unix_local (timestamp).format ("%m/%d/%y %H:%M");
                time = datetime.to_string();
            } catch (Error e) {
                warning (e.message);
            }

            return true;
        }

    }
}
