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
    public class MainWindow : Gtk.ApplicationWindow {
        public Gtk.Label label_result;
        public Gtk.Label label_info;
        public Gtk.Label label_history;
        public Gtk.ComboBoxText base_currency;
        public Gtk.ComboBoxText base_vcurrency;
        public Gtk.Stack stack;
        public Gtk.Image aicon;

        public double avg;
        public double avg_history;
        public string coin_iso;
        public string vcoin_iso;

        public MainWindow (Gtk.Application application) {
            GLib.Object (application: application,
                         icon_name: "com.github.lainsce.coin",
                         resizable: false,
                         height_request: 280,
                         width_request: 500,
                         border_width: 6
            );
        }

        construct {
            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("/com/github/lainsce/coin/stylesheet.css");
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            set_keep_below (true);
            stick ();

            var titlebar = new Gtk.HeaderBar ();
            titlebar.has_subtitle = false;
            titlebar.show_close_button = true;


            var titlebar_style_context = titlebar.get_style_context ();
            titlebar_style_context.add_class (Gtk.STYLE_CLASS_FLAT);
            titlebar_style_context.add_class ("default-decoration");
            titlebar_style_context.add_class ("coin-toolbar");

            this.set_titlebar (titlebar);

            var settings = AppSettings.get_default ();
            this.get_style_context ().add_class ("rounded");

            var icon = new Gtk.Image.from_icon_name ("com.github.lainsce.coin-symbolic", Gtk.IconSize.DIALOG);

            base_currency = new Gtk.ComboBoxText();
            base_currency.append_text(_("US Dollar"));
            base_currency.append_text(_("Euro"));
            base_currency.append_text(_("British Pound"));
            base_currency.append_text(_("Australian Dollar"));
            base_currency.append_text(_("Brazilian Real"));
            base_currency.append_text(_("Canadian Dollar"));
            base_currency.append_text(_("Chinese Yuan"));
            base_currency.append_text(_("Indian Rupee"));
            base_currency.append_text(_("Japanese Yen"));
            base_currency.append_text(_("Russian Ruble"));
            base_currency.append_text(_("S. African Rand"));
            base_currency.margin = 6;

            if (settings.coin == 0) {
                base_currency.set_active(0);
                coin_iso = "USD";
            } else if (settings.coin == 1) {
                base_currency.set_active(1);
                coin_iso = "EUR";
            } else if (settings.coin == 2) {
                base_currency.set_active(2);
                coin_iso = "GBP";
            } else if (settings.coin == 3) {
                base_currency.set_active(3);
                coin_iso = "AUD";
            } else if (settings.coin == 4) {
                base_currency.set_active(4);
                coin_iso = "BRL";
            } else if (settings.coin == 5) {
                base_currency.set_active(5);
                coin_iso = "CAD";
            } else if (settings.coin == 6) {
                base_currency.set_active(6);
                coin_iso = "CNY";
            } else if (settings.coin == 7) {
                base_currency.set_active(7);
                coin_iso = "INR";
            } else if (settings.coin == 8) {
                base_currency.set_active(8);
                coin_iso = "JPY";
            } else if (settings.coin == 9) {
                base_currency.set_active(9);
                coin_iso = "RUB";
            } else if (settings.coin == 10) {
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
            base_vcurrency.append_text("Bitcoin Cash");
            base_vcurrency.append_text("Cardano");
            base_vcurrency.append_text("Tezos");
            base_vcurrency.margin = 6;

            if (settings.virtualcoin == 0) {
                base_vcurrency.set_active(0);
                vcoin_iso = "BTC";
            } else if (settings.virtualcoin == 1) {
                base_vcurrency.set_active(1);
                vcoin_iso = "DASH";
            } else if (settings.virtualcoin == 2) {
                base_vcurrency.set_active(2);
                vcoin_iso = "ETH";
            } else if (settings.virtualcoin == 3) {
                base_vcurrency.set_active(3);
                vcoin_iso = "LTC";
            } else if (settings.virtualcoin == 4) {
                base_vcurrency.set_active(4);
                vcoin_iso = "PPC";
            } else if (settings.virtualcoin == 5) {
                base_vcurrency.set_active(5);
                vcoin_iso = "XRP";
            } else if (settings.virtualcoin == 6) {
                base_vcurrency.set_active(6);
                vcoin_iso = "ZEC";
            } else if (settings.virtualcoin == 7) {
                base_vcurrency.set_active(7);
                vcoin_iso = "XMR";
            } else if (settings.virtualcoin == 8) {
                base_vcurrency.set_active(8);
                vcoin_iso = "BCH";
            } else if (settings.virtualcoin == 9) {
                base_vcurrency.set_active(9);
                vcoin_iso = "ADA";
            } else if (settings.virtualcoin == 10) {
                base_vcurrency.set_active(10);
                vcoin_iso = "XTZ";
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
            label_history = new Gtk.Label ("");
            label_result.set_halign (Gtk.Align.START);

            aicon = new Gtk.Image ();
            aicon.icon_size = Gtk.IconSize.SMALL_TOOLBAR;

            if (avg_history <= 0.0) {
                aicon.icon_name = "go-down-symbolic";
                var context = aicon.get_style_context ();
                context.add_class ("negative-icon");
                context.remove_class ("positive-icon");
            } else {
                aicon.icon_name = "go-up-symbolic";
                var context = aicon.get_style_context ();
                context.remove_class ("negative-icon");
                context.add_class ("positive-icon");
            }

            get_values ();
            set_labels ();

            var avg_grid = new Gtk.Grid ();
            avg_grid.margin_top = 0;
            avg_grid.margin_start = 6;
            avg_grid.column_spacing = 6;
            avg_grid.attach (aicon, 0, 0, 1, 1);
            avg_grid.attach (label_history, 1, 0, 1, 1);

            var grid = new Gtk.Grid ();
            grid.margin_top = 0;
            grid.column_homogeneous = true;
            grid.column_spacing = 6;
            grid.row_spacing = 6;
            grid.attach (icon, 0, 2, 1, 1);
            grid.attach (base_currency, 0, 1, 2, 1);
            grid.attach (base_vcurrency, 2, 1, 2, 1);
            grid.attach (label_result, 1, 2, 3, 2);
            grid.attach (avg_grid, 0, 4, 1, 1);
            grid.attach (label_info, 1, 4, 3, 2);

            stack = new Gtk.Stack ();
            stack.transition_type = Gtk.StackTransitionType.CROSSFADE;
            stack.margin = 6;
            stack.margin_top = 0;
            stack.homogeneous = true;
            stack.add_named (grid, "money");

            this.add (stack);
            stack.show_all ();

            base_currency.changed.connect (() => {
                get_values ();
                set_labels ();

                if (avg_history <= 0.0) {
                    aicon.icon_name = "go-down-symbolic";
                    var context = aicon.get_style_context ();
                    context.add_class ("negative-icon");
                    context.remove_class ("positive-icon");
                } else {
                    aicon.icon_name = "go-up-symbolic";
                    var context = aicon.get_style_context ();
                    context.remove_class ("negative-icon");
                    context.add_class ("positive-icon");
                }
            });

            base_vcurrency.changed.connect (() => {
                get_values ();
                set_labels ();

                if (avg_history <= 0.0) {
                    aicon.icon_name = "go-down-symbolic";
                    var context = aicon.get_style_context ();
                    context.add_class ("negative-icon");
                    context.remove_class ("positive-icon");
                } else {
                    aicon.icon_name = "go-up-symbolic";
                    var context = aicon.get_style_context ();
                    context.remove_class ("negative-icon");
                    context.add_class ("positive-icon");
                }
            });

            Timeout.add_seconds (10, () => {
                get_values ();
                set_labels ();

                if (avg_history <= 0.0) {
                    aicon.icon_name = "go-down-symbolic";
                    var context = aicon.get_style_context ();
                    context.add_class ("negative-icon");
                    context.remove_class ("positive-icon");
                } else {
                    aicon.icon_name = "go-up-symbolic";
                    var context = aicon.get_style_context ();
                    context.remove_class ("negative-icon");
                    context.add_class ("positive-icon");
                }
            });

            int x = settings.window_x;
            int y = settings.window_y;
            int coin = base_currency.get_active();
            coin = settings.coin;
            int vcoin = base_vcurrency.get_active();
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
            settings.coin = base_currency.get_active();
            settings.virtualcoin = base_vcurrency.get_active();

            return false;
        }

        public bool get_values () {
            var settings = AppSettings.get_default ();
            settings.coin = base_currency.get_active();
            if (settings.coin == 0) {
                coin_iso = "USD";
            } else if (settings.coin == 1) {
                coin_iso = "EUR";
            } else if (settings.coin == 2) {
                coin_iso = "GBP";
            } else if (settings.coin == 3) {
                coin_iso = "AUD";
            } else if (settings.coin == 4) {
                coin_iso = "BRL";
            } else if (settings.coin == 5) {
                coin_iso = "CAD";
            } else if (settings.coin == 6) {
                coin_iso = "CNY";
            } else if (settings.coin == 7) {
                coin_iso = "INR";
            } else if (settings.coin == 8) {
                coin_iso = "JPY";
            } else if (settings.coin == 9) {
                coin_iso = "RUB";
            } else if (settings.coin == 10) {
                coin_iso = "ZAR";
            } else {
                base_currency.set_active(0);
                coin_iso = "USD";
            }

            debug ("Chose %s".printf(coin_iso));

            settings.virtualcoin = base_vcurrency.get_active();
            if (settings.virtualcoin == 0) {
                vcoin_iso = "BTC";
            } else if (settings.virtualcoin == 1) {
                vcoin_iso = "DASH";
            } else if (settings.virtualcoin == 2) {
                vcoin_iso = "ETH";
            } else if (settings.virtualcoin == 3) {
                vcoin_iso = "LTC";
            } else if (settings.virtualcoin == 4) {
                vcoin_iso = "PPC";
            } else if (settings.virtualcoin == 5) {
                vcoin_iso = "XRP";
            } else if (settings.virtualcoin == 6) {
                vcoin_iso = "ZEC";
            } else if (settings.virtualcoin == 7) {
                vcoin_iso = "XMR";
            } else if (settings.virtualcoin == 8) {
                vcoin_iso = "BCH";
            } else if (settings.virtualcoin == 9){
                vcoin_iso = "ADA";
            } else if (settings.virtualcoin == 10){
                vcoin_iso = "XTZ";
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
                avg_history = to_object.get_double_member("CHANGE24HOUR");
            } catch (Error e) {
                warning ("Failed to connect to service: %s", e.message);
            }

            return true;
        }

        public void set_labels () {
            var settings = AppSettings.get_default ();
            var curr_symbol = "";
            settings.coin = base_currency.get_active();
            switch (settings.coin) {
                case 4:
                    curr_symbol = "R$";
                    break;
                case 10:
                    curr_symbol = "R";
                    break;
                case 1:
                    curr_symbol = "€";
                    break;
                case 2:
                    curr_symbol = "£";
                    break;
                case 0:
                case 3:
                case 5:
                    curr_symbol = "$";
                    break;
                case 8:
                case 6:
                    curr_symbol = "¥";
                    break;
                case 9:
                    curr_symbol = "₽";
                    break;
                case 7:
                    curr_symbol = "₹";
                    break;
                default:
                    curr_symbol = "¤";
                break;
            }

            var vcurr_symbol = "";
            settings.virtualcoin = base_vcurrency.get_active();
            switch (settings.virtualcoin) {
                case 0:
                    vcurr_symbol = "₿";
                    break;
                case 1:
                    vcurr_symbol = "ⅅ";
                    break;
                case 2:
                    vcurr_symbol = "Ξ";
                    break;
                case 3:
                    vcurr_symbol = "Ł";
                    break;
                case 4:
                    vcurr_symbol = "þ";
                    break;
                case 5:
                    vcurr_symbol = "Ʀ";
                    break;
                case 6:
                    vcurr_symbol = "ℨ";
                    break;
                case 7:
                    vcurr_symbol = "ɱ";
                    break;
                case 8:
                    vcurr_symbol = "BC";
                    break;
                case 9:
                    vcurr_symbol = "ADA";
                    break;
                case 10:
                    vcurr_symbol = "XTZ";
                    break;
                default:
                    curr_symbol = "¬";
                break;
            }

            label_result.set_markup ("""<span font="22">%s</span> <span font="30">%.1f</span> <span font="18">/ 1 %s</span>""".printf(curr_symbol, avg, vcurr_symbol));

            label_history.set_markup ("""<span font="10">%.1f</span>""".printf(avg_history));
        }
    }
}
