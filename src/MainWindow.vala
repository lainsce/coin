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
        public string coin_iso;
        public string vcoin_iso;

        public MainWindow (Gtk.Application application) {
            GLib.Object (application: application,
                        icon_name: "com.github.lainsce.coin",
                        resizable: false,
                        title: _("Coin"),
                        height_request: 280,
                        width_request: 500,
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
            base_currency.append_text("US Dollar");
            base_currency.append_text("Euro");
            base_currency.append_text("British Pound");
            base_currency.append_text("Australian Dollar");
		    base_currency.append_text("Brazilian Real");
		    base_currency.append_text("Canadian Dollar");
		    base_currency.append_text("Chinese Yuan");
		    base_currency.append_text("Indian Ruppee");
		    base_currency.append_text("Japanese Yen");
		    base_currency.append_text("Russian Ruble");
            base_currency.append_text("South African Rand");
		    base_currency.margin = 6;

            if (settings.coin == "US Dollar") {
                base_currency.set_active(0);
                coin_iso = "USD";
            } else if (settings.coin == "Euro") {
                base_currency.set_active(1);
                coin_iso = "EUR";
            } else if (settings.coin == "British Pound") {
                base_currency.set_active(2);
                coin_iso = "GBP";
            } else if (settings.coin == "Australian Dollar") {
                base_currency.set_active(3);
                coin_iso = "AUD";
            } else if (settings.coin == "Brazilian Real") {
                base_currency.set_active(4);
                coin_iso = "BRL";
            } else if (settings.coin == "Canadian Dollar") {
                base_currency.set_active(5);
                coin_iso = "CAD";
            } else if (settings.coin == "Chinese Yuan") {
                base_currency.set_active(6);
                coin_iso = "CNY";
            } else if (settings.coin == "Indian Ruppee") {
                base_currency.set_active(7);
                coin_iso = "INR";
            } else if (settings.coin == "Japanese Yen") {
                base_currency.set_active(8);
                coin_iso = "JPY";
            } else if (settings.coin == "Russian Ruble") {
                base_currency.set_active(9);
                coin_iso = "RUB";
            } else if (settings.coin == "South African Rand") {
                base_currency.set_active(10);
                coin_iso = "ZAR";
            } else {
                base_currency.set_active(0);
                coin_iso = "USD";
            }

            base_vcurrency = new Gtk.ComboBoxText();
		    base_vcurrency.append_text("Bitcoin");
		    base_vcurrency.append_text("Dashcoin");
		    base_vcurrency.append_text("Ethereum");
		    base_vcurrency.append_text("Litecoin");
		    base_vcurrency.append_text("Peercoin");
		    base_vcurrency.append_text("Ripple");
		    base_vcurrency.append_text("ZCash");
            base_vcurrency.append_text("Monero");
		    base_vcurrency.margin = 6;

            if (settings.virtualcoin == "Bitcoin") {
                base_vcurrency.set_active(0);
                vcoin_iso = "BTC";
            } else if (settings.virtualcoin == "Dashcoin") {
                base_vcurrency.set_active(1);
                vcoin_iso = "DASH";
            } else if (settings.virtualcoin == "Ethereum") {
                base_vcurrency.set_active(2);
                vcoin_iso = "ETH";
            } else if (settings.virtualcoin == "Litecoin") {
                base_vcurrency.set_active(3);
                vcoin_iso = "LTC";
            } else if (settings.virtualcoin == "Peercoin") {
                base_vcurrency.set_active(4);
                vcoin_iso = "PPC";
            } else if (settings.virtualcoin == "Ripple") {
                base_vcurrency.set_active(5);
                vcoin_iso = "XRP";
            } else if (settings.virtualcoin == "ZCash") {
                base_vcurrency.set_active(6);
                vcoin_iso = "ZEC";
            } else if (settings.virtualcoin == "Monero") {
                base_vcurrency.set_active(7);
                vcoin_iso = "XMR";
            } else {
                base_vcurrency.set_active(0);
                vcoin_iso = "BTC";
            }

            label_result = new Gtk.Label ("");
            label_result.set_halign (Gtk.Align.END);
            label_result.hexpand = true;
            label_info = new Gtk.Label (_("Updated every 10 seconds"));
            label_info.set_halign (Gtk.Align.END);
            label_info.hexpand = true;
            get_values ();
            set_labels ();

            var grid = new Gtk.Grid ();
            grid.margin_top = 0;
            grid.column_homogeneous = true;
            grid.column_spacing = 6;
            grid.row_spacing = 6;
            grid.attach (icon, 0, 2, 1, 1);
            grid.attach (base_currency, 0, 1, 2, 1);
            grid.attach (base_vcurrency, 2, 1, 2, 1);
            grid.attach (label_result, 1, 2, 3, 2);
            grid.attach (label_info, 1, 4, 3, 2);

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
            if (settings.coin == "Brazilian Real") {
                coin_iso = "BRL";
            } else if (settings.coin == "South African Rand") {
                coin_iso = "ZAR";
            } else if (settings.coin == "Euro") {
                coin_iso = "EUR";
            } else if (settings.coin == "British Pound") {
                coin_iso = "GBP";
            } else if (settings.coin == "US Dollar") {
                coin_iso = "USD";
            } else if (settings.coin == "Australian Dollar") {
                coin_iso = "AUD";
            } else if (settings.coin == "Canadian Dollar") {
                coin_iso = "CAD";
            } else if (settings.coin == "Japanese Yen") {
                coin_iso = "JPY";
            } else if (settings.coin == "Chinese Yuan") {
                coin_iso = "CNY";
            } else if (settings.coin == "Russian Ruble") {
                coin_iso = "RUB";
            } else if (settings.coin == "Indian Ruppee") {
                coin_iso = "INR";
            }

            debug ("Chose %s".printf(coin_iso));

            settings.virtualcoin = base_vcurrency.get_active_text();
            if (settings.virtualcoin == "Bitcoin") {
                vcoin_iso = "BTC";
            } else if (settings.virtualcoin == "Dashcoin") {
                vcoin_iso = "DASH";
            } else if (settings.virtualcoin == "Ethereum") {
                vcoin_iso = "ETH";
            } else if (settings.virtualcoin == "Litecoin") {
                vcoin_iso = "LTC";
            } else if (settings.virtualcoin == "Peercoin") {
                vcoin_iso = "PPC";
            } else if (settings.virtualcoin == "Ripple") {
                vcoin_iso = "XRP";
            } else if (settings.virtualcoin == "ZCash") {
                vcoin_iso = "ZEC";
            } else if (settings.virtualcoin == "Monero") {
                vcoin_iso = "XMR";
            }
            debug ("Chose %s".printf(vcoin_iso));

            var uri = """https://min-api.cryptocompare.com/data/pricemultifull?fsyms=%s&tsyms=%s""".printf(vcoin_iso, coin_iso);
            debug("URL is %s".printf(uri));
            var session = new Soup.Session ();
            var message = new Soup.Message ("GET", uri);
            session.send_message (message);

            try {
                var parser = new Json.Parser ();
                parser.load_from_data ((string) message.response_body.flatten ().data, -1);
                var root_object = parser.get_root ().get_object();
                var response_object = root_object.get_object_member ("RAW");
                var from_object = response_object.get_object_member ("%s".printf(vcoin_iso));
                var to_object = from_object.get_object_member ("%s".printf(coin_iso));
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
                case "Brazilian Real":
                    curr_symbol = "R$";
                    break;
                case "South African Rand":
                    curr_symbol = "R";
                    break;
                case "Euro":
                    curr_symbol = "€";
                    break;
                case "British Pound":
                    curr_symbol = "£";
                    break;
                case "US Dollar":
                case "Australian Dollar":
                case "Canadian Dollar":
                    curr_symbol = "$";
                    break;
                case "Japanese Yen":
                case "Chinese Yuan":
                    curr_symbol = "¥";
                    break;
                case "Russian Ruble":
                    curr_symbol = "₽";
                    break;
                case "Indian Ruppee":
                    curr_symbol = "₹";
                    break;
                default:
                    curr_symbol = "¤";
                    break;
            }

            var vcurr_symbol = "";
            settings.virtualcoin = base_vcurrency.get_active_text();
            switch (settings.virtualcoin) {
                case "Bitcoin":
                    vcurr_symbol = "Ƀ";
                    break;
                case "Dashcoin":
                    vcurr_symbol = "ⅅ";
                    break;
                case "Ethereum":
                    vcurr_symbol = "Ξ";
                    break;
                case "Litecoin":
                    vcurr_symbol = "Ł";
                    break;
                case "Peercoin":
                    vcurr_symbol = "þ";
                    break;
                case "Ripple":
                    vcurr_symbol = "Ʀ";
                    break;
                case "ZCash":
                    vcurr_symbol = "ℨ";
                    break;
                case "Monero":
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
