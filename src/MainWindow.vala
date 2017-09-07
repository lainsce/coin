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
        public Gtk.Label label_eth_result;
        public Gtk.ComboBoxText base_currency;
        public Gtk.ComboBoxText base_vcurrency;
        public Gtk.Stack stack;

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

            make_ui ();
            Timeout.add_seconds (10, () => {
                get_values ();
                set_labels ();
            });

            var settings = AppSettings.get_default ();

            int x = settings.window_x;
            int y = settings.window_y;

            if (x != -1 && y != -1) {
                move (x, y);
            }

            button_press_event.connect ((e) => {
                if (e.button == Gdk.BUTTON_PRIMARY) {
                    begin_move_drag ((int) e.button, (int) e.x_root, (int) e.y_root, e.time);
                    return true;
                }
                return false;
            });
        }

        public override bool delete_event (Gdk.EventAny event) {
            int x, y;
            get_position (out x, out y);

            var settings = AppSettings.get_default ();
            settings.window_x = x;
            settings.window_y = y;

            return false;
        }

        public async void make_ui () {
            var icon = new Gtk.Image.from_icon_name ("com.github.lainsce.coin-symbolic", Gtk.IconSize.DIALOG);

            base_currency = new Gtk.ComboBoxText();
            base_currency.append_text("USD");
            base_currency.append_text("EUR");
            base_currency.append_text("GBP");
            base_currency.append_text("AUD");
		    base_currency.append_text("BRL");
		    base_currency.append_text("CAD");
		    base_currency.append_text("CNY");
		    base_currency.append_text("INR");
		    base_currency.append_text("JPY");
		    base_currency.append_text("RUB");
		    base_currency.set_active(0);
		    base_currency.margin = 6;

            base_vcurrency = new Gtk.ComboBoxText();
		    base_vcurrency.append_text("BTC");
		    base_vcurrency.append_text("DASH");
		    base_vcurrency.append_text("DGB");
		    base_vcurrency.append_text("ETH");
		    base_vcurrency.append_text("LTC");
		    base_vcurrency.append_text("PPC");
		    base_vcurrency.append_text("XRP");
            base_vcurrency.append_text("XAR");
		    base_vcurrency.append_text("ZEC");
            base_vcurrency.append_text("XMR");
            base_vcurrency.append_text("DOGE");
		    base_vcurrency.set_active(0);
		    base_vcurrency.margin = 6;

            label_result = new Gtk.Label ("");
            label_info = new Gtk.Label (_("Updated every 10 seconds"));
            label_info.set_halign (Gtk.Align.END);
            get_values ();
            set_labels ();

            var grid = new Gtk.Grid ();
            grid.column_spacing = 32;
            grid.margin_start = 18;
            grid.margin_end = 18;
            grid.margin_bottom = 6;
            grid.attach (icon, 0, 1, 1, 1);
            grid.attach (label_result, 1, 1, 3, 1);
            grid.attach (label_info, 1, 2, 3, 1);
            grid.attach (base_currency, 0, 2, 1, 1);
            grid.attach (base_vcurrency, 0, 0, 1, 1);

            stack = new Gtk.Stack ();
            stack.transition_type = Gtk.StackTransitionType.CROSSFADE;
            stack.vhomogeneous = true;
            stack.add_named (grid, "money");


            var content_box = get_content_area () as Gtk.Box;
            content_box.border_width = 0;
            content_box.add (stack);
            content_box.show_all ();

            base_currency.changed.connect (() => {
                get_values ();
                set_labels ();
            });

            base_vcurrency.changed.connect (() => {
                get_values ();
                set_labels ();
            });
        }

        public bool get_values () {
            var curname = base_currency.get_active_text();
            var vcurname = base_vcurrency.get_active_text();
            var uri = """https://min-api.cryptocompare.com/data/pricemultifull?fsyms=%s&tsyms=%s""".printf(vcurname, curname);
            var session = new Soup.Session ();
            var message = new Soup.Message ("GET", uri);
            session.send_message (message);

            try {
                var parser = new Json.Parser ();
                parser.load_from_data ((string) message.response_body.flatten ().data, -1);
                var root_object = parser.get_root ().get_object();
                var response_object = root_object.get_object_member ("RAW");
                var from_object = response_object.get_object_member ("%s".printf(vcurname));
                var to_object = from_object.get_object_member ("%s".printf(curname));
                avg = to_object.get_double_member("PRICE");
            } catch (Error e) {
                warning ("Failed to connect to service: %s", e.message);
            }

            return true;
        }

        public void set_labels () {
            var curr_symbol = "";
            var curname = base_currency.get_active_text();
            switch (curname) {
                case "BRL":
                    curr_symbol = "R$";
                    break;
                case "ZAR":
                    curr_symbol = "R";
                    break;
                case "EUR":
                    curr_symbol = "€";
                    break;
                case "GBP":
                    curr_symbol = "£";
                    break;
                case "USD":
                case "AUD":
                case "CAD":
                    curr_symbol = "$";
                    break;
                case "JPY":
                case "CNY":
                    curr_symbol = "¥";
                    break;
                case "RUB":
                    curr_symbol = "₽";
                    break;
                case "INR":
                    curr_symbol = "₹";
                    break;
                default:
                    curr_symbol = "¤";
                    break;
            }

            var vcurr_symbol = "";
            var vcurname = base_vcurrency.get_active_text();
            switch (vcurname) {
                case "BTC":
                    vcurr_symbol = "Ƀ";
                    break;
                case "DASH":
                    vcurr_symbol = "ⅅ";
                    break;
                case "DGB":
                    vcurr_symbol = "Ð";
                    break;
                case "ETH":
                    vcurr_symbol = "Ξ";
                    break;
                case "LTC":
                    vcurr_symbol = "Ł";
                    break;
                case "PPC":
                    vcurr_symbol = "þ";
                    break;
                case "XRP":
                    vcurr_symbol = "Ʀ";
                    break;
                case "XAR":
                    vcurr_symbol = "X";
                    break;
                case "ZEC":
                    vcurr_symbol = "ℨ";
                    break;
                case "XMR":
                    vcurr_symbol = "ɱ";
                    break;
                case "DOGE":
                    vcurr_symbol = "D$";
                    break;
            }

            label_result.set_markup ("""<span font="22">%s</span> <span font="28">%.2f</span> <span font="16">/ 1 %s</span>""".printf(curr_symbol, avg, vcurr_symbol));
        }
    }
}
