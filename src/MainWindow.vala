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
                        height_request: 270,
                        width_request: 510,
                        border_width: 0,
                        window_position: Gtk.WindowPosition.CENTER
            );
        }

        construct {
            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("/com/github/lainsce/coin/stylesheet.css");
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            set_keep_below (true);
            stick ();

            var settings = AppSettings.get_default ();
            this.get_style_context ().add_class ("rounded");

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
            base_currency.append_text("ZAR");
		    base_currency.margin = 6;

            if (settings.coin == "USD") {
                base_currency.set_active(0);
            } else if (settings.coin == "EUR") {
                base_currency.set_active(1);
            } else if (settings.coin == "GBP") {
                base_currency.set_active(2);
            } else if (settings.coin == "AUD") {
                base_currency.set_active(3);
            } else if (settings.coin == "BRL") {
                base_currency.set_active(4);
            } else if (settings.coin == "CAD") {
                base_currency.set_active(5);
            } else if (settings.coin == "CNY") {
                base_currency.set_active(6);
            } else if (settings.coin == "INR") {
                base_currency.set_active(7);
            } else if (settings.coin == "JPY") {
                base_currency.set_active(8);
            } else if (settings.coin == "RUB") {
                base_currency.set_active(9);
            } else if (settings.coin == "ZAR") {
                base_currency.set_active(10);
            } else {
                base_currency.set_active(0);
            }

            base_vcurrency = new Gtk.ComboBoxText();
		    base_vcurrency.append_text("BTC");
		    base_vcurrency.append_text("DASH");
		    base_vcurrency.append_text("ETH");
		    base_vcurrency.append_text("LTC");
		    base_vcurrency.append_text("PPC");
		    base_vcurrency.append_text("XRP");
		    base_vcurrency.append_text("ZEC");
            base_vcurrency.append_text("XMR");
		    base_vcurrency.margin = 6;

            if (settings.virtualcoin == "BTC") {
                base_vcurrency.set_active(0);
            } else if (settings.virtualcoin == "DASH") {
                base_vcurrency.set_active(1);
            } else if (settings.virtualcoin == "ETH") {
                base_vcurrency.set_active(2);
            } else if (settings.virtualcoin == "LTC") {
                base_vcurrency.set_active(3);
            } else if (settings.virtualcoin == "PPC") {
                base_vcurrency.set_active(4);
            } else if (settings.virtualcoin == "XRP") {
                base_vcurrency.set_active(5);
            } else if (settings.virtualcoin == "ZEC") {
                base_vcurrency.set_active(6);
            } else if (settings.virtualcoin == "XMR") {
                base_vcurrency.set_active(7);
            } else {
                base_vcurrency.set_active(0);
            }

            label_result = new Gtk.Label ("");
            label_result.set_halign (Gtk.Align.START);
            label_result.hexpand = true;
            label_info = new Gtk.Label (_("Updated every 10 seconds"));
            label_info.set_halign (Gtk.Align.END);
            label_info.hexpand = true;
            get_values ();
            set_labels ();

            var grid = new Gtk.Grid ();
            grid.margin_top = 0;
            grid.column_spacing = 12;
            grid.row_spacing = 6;
            grid.attach (icon, 0, 1, 1, 1);
            grid.attach (label_result, 1, 1, 1, 1);
            grid.attach (label_info, 1, 2, 1, 1);
            grid.attach (base_currency, 0, 2, 1, 1);
            grid.attach (base_vcurrency, 0, 0, 1, 1);

            stack = new Gtk.Stack ();
            stack.transition_type = Gtk.StackTransitionType.CROSSFADE;
            stack.margin = 6;
            stack.margin_top = 0;
            stack.homogeneous = true;
            stack.add_named (grid, "money");

            ((Gtk.Container) get_content_area ()).add (stack);
            stack.show_all ();

            base_currency.changed.connect (() => {
                get_values ();
                set_labels ();
            });

            base_vcurrency.changed.connect (() => {
                get_values ();
                set_labels ();
            });

            Timeout.add_seconds (10, () => {
                get_values ();
                set_labels ();
            });

            int x = settings.window_x;
            int y = settings.window_y;
            string coin = base_currency.get_active_text();
            coin = settings.coin;
            string vcoin = base_vcurrency.get_active_text();
            vcoin = settings.virtualcoin;

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
            settings.coin = base_currency.get_active_text();
            settings.virtualcoin = base_vcurrency.get_active_text();

            return false;
        }

        public bool get_values () {
            var settings = AppSettings.get_default ();
            settings.coin = base_currency.get_active_text();
            settings.virtualcoin = base_vcurrency.get_active_text();
            var uri = """https://min-api.cryptocompare.com/data/pricemultifull?fsyms=%s&tsyms=%s""".printf(settings.virtualcoin, settings.coin);
            var session = new Soup.Session ();
            var message = new Soup.Message ("GET", uri);
            session.send_message (message);

            try {
                var parser = new Json.Parser ();
                parser.load_from_data ((string) message.response_body.flatten ().data, -1);
                var root_object = parser.get_root ().get_object();
                var response_object = root_object.get_object_member ("RAW");
                var from_object = response_object.get_object_member ("%s".printf(settings.virtualcoin));
                var to_object = from_object.get_object_member ("%s".printf(settings.coin));
                avg = to_object.get_double_member("PRICE");
            } catch (Error e) {
                warning ("Failed to connect to service: %s", e.message);
            }

            return true;
        }

        public void set_labels () {
            var settings = AppSettings.get_default ();
            var curr_symbol = "";
            settings.coin = base_currency.get_active_text();
            switch (settings.coin) {
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
                case "INR":
                    curr_symbol = "₹";
                    break;
                default:
                    curr_symbol = "¤";
                    break;
            }

            var vcurr_symbol = "";
            settings.virtualcoin = base_vcurrency.get_active_text();
            switch (settings.virtualcoin) {
                case "BTC":
                    vcurr_symbol = "Ƀ";
                    break;
                case "DASH":
                    vcurr_symbol = "ⅅ";
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
                case "ZEC":
                    vcurr_symbol = "ℨ";
                    break;
                case "XMR":
                    vcurr_symbol = "ɱ";
                    break;
                default:
                    curr_symbol = "¬";
                    break;
            }

            label_result.set_markup ("""<span font="22">%s</span> <span font="30">%.1f</span> <span font="18">/ 1 %s</span>""".printf(curr_symbol, avg, vcurr_symbol));
        }
    }
}
