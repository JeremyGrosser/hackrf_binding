--
--  Copyright (C) 2022 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
pragma Ada_2012;
pragma Style_Checks (Off);

with Interfaces.C; use Interfaces.C;
with Interfaces;
with System;
with Interfaces.C.Strings;

package libhackrf is

   SAMPLES_PER_BLOCK : constant := 8192;  --  /usr/local/include/libhackrf/hackrf.h:50
   BYTES_PER_BLOCK : constant := 16384;  --  /usr/local/include/libhackrf/hackrf.h:51
   MAX_SWEEP_RANGES : constant := 10;  --  /usr/local/include/libhackrf/hackrf.h:52
   HACKRF_OPERACAKE_ADDRESS_INVALID : constant := 16#FF#;  --  /usr/local/include/libhackrf/hackrf.h:53

   subtype hackrf_error is int;
   HACKRF_SUCCESS : constant int := 0;
   HACKRF_TRUE : constant int := 1;
   HACKRF_ERROR_INVALID_PARAM : constant int := -2;
   HACKRF_ERROR_NOT_FOUND : constant int := -5;
   HACKRF_ERROR_BUSY : constant int := -6;
   HACKRF_ERROR_NO_MEM : constant int := -11;
   HACKRF_ERROR_LIBUSB : constant int := -1000;
   HACKRF_ERROR_THREAD : constant int := -1001;
   HACKRF_ERROR_STREAMING_THREAD_ERR : constant int := -1002;
   HACKRF_ERROR_STREAMING_STOPPED : constant int := -1003;
   HACKRF_ERROR_STREAMING_EXIT_CALLED : constant int := -1004;
   HACKRF_ERROR_USB_API_VERSION : constant int := -1005;
   HACKRF_ERROR_NOT_LAST_DEVICE : constant int := -2000;
   HACKRF_ERROR_OTHER : constant int := -9999;  -- /usr/local/include/libhackrf/hackrf.h:55

   subtype hackrf_board_id is unsigned;
   BOARD_ID_JELLYBEAN : constant unsigned := 0;
   BOARD_ID_JAWBREAKER : constant unsigned := 1;
   BOARD_ID_HACKRF_ONE : constant unsigned := 2;
   BOARD_ID_RAD1O : constant unsigned := 3;
   BOARD_ID_INVALID : constant unsigned := 255;  -- /usr/local/include/libhackrf/hackrf.h:72

   subtype hackrf_usb_board_id is unsigned;
   USB_BOARD_ID_JAWBREAKER : constant unsigned := 24651;
   USB_BOARD_ID_HACKRF_ONE : constant unsigned := 24713;
   USB_BOARD_ID_RAD1O : constant unsigned := 52245;
   USB_BOARD_ID_INVALID : constant unsigned := 65535;  -- /usr/local/include/libhackrf/hackrf.h:80

   type rf_path_filter is
     (RF_PATH_FILTER_BYPASS,
      RF_PATH_FILTER_LOW_PASS,
      RF_PATH_FILTER_HIGH_PASS)
   with Convention => C;  -- /usr/local/include/libhackrf/hackrf.h:87

   type operacake_ports is
     (OPERACAKE_PA1,
      OPERACAKE_PA2,
      OPERACAKE_PA3,
      OPERACAKE_PA4,
      OPERACAKE_PB1,
      OPERACAKE_PB2,
      OPERACAKE_PB3,
      OPERACAKE_PB4)
   with Convention => C;  -- /usr/local/include/libhackrf/hackrf.h:93

   type sweep_style is
     (LINEAR,
      INTERLEAVED)
   with Convention => C;  -- /usr/local/include/libhackrf/hackrf.h:104

   type hackrf_device is null record;   -- incomplete struct

   type hackrf_transfer is record
      device : access hackrf_device;  -- /usr/local/include/libhackrf/hackrf.h:112
      buffer : access Interfaces.Unsigned_8;  -- /usr/local/include/libhackrf/hackrf.h:113
      buffer_length : aliased int;  -- /usr/local/include/libhackrf/hackrf.h:114
      valid_length : aliased int;  -- /usr/local/include/libhackrf/hackrf.h:115
      rx_ctx : System.Address;  -- /usr/local/include/libhackrf/hackrf.h:116
      tx_ctx : System.Address;  -- /usr/local/include/libhackrf/hackrf.h:117
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/libhackrf/hackrf.h:118

   type read_partid_serialno_t_array908 is array (0 .. 1) of aliased Interfaces.Unsigned_32;
   type read_partid_serialno_t_array911 is array (0 .. 3) of aliased Interfaces.Unsigned_32;
   type read_partid_serialno_t is record
      part_id : aliased read_partid_serialno_t_array908;  -- /usr/local/include/libhackrf/hackrf.h:121
      serial_no : aliased read_partid_serialno_t_array911;  -- /usr/local/include/libhackrf/hackrf.h:122
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/libhackrf/hackrf.h:123

   type hackrf_device_list is record
      serial_numbers : System.Address;  -- /usr/local/include/libhackrf/hackrf.h:127
      usb_board_ids : access hackrf_usb_board_id;  -- /usr/local/include/libhackrf/hackrf.h:128
      usb_device_index : access int;  -- /usr/local/include/libhackrf/hackrf.h:129
      devicecount : aliased int;  -- /usr/local/include/libhackrf/hackrf.h:130
      usb_devices : System.Address;  -- /usr/local/include/libhackrf/hackrf.h:132
      usb_devicecount : aliased int;  -- /usr/local/include/libhackrf/hackrf.h:133
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/libhackrf/hackrf.h:126

   subtype hackrf_device_list_t is hackrf_device_list;  -- /usr/local/include/libhackrf/hackrf.h:135

   type hackrf_sample_block_cb_fn is access function (arg1 : access hackrf_transfer) return int
   with Convention => C;  -- /usr/local/include/libhackrf/hackrf.h:137

   function hackrf_init return int  -- /usr/local/include/libhackrf/hackrf.h:144
   with Import => True,
        Convention => C,
        External_Name => "hackrf_init";

   function hackrf_exit return int  -- /usr/local/include/libhackrf/hackrf.h:145
   with Import => True,
        Convention => C,
        External_Name => "hackrf_exit";

   function hackrf_library_version return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/libhackrf/hackrf.h:147
   with Import => True,
        Convention => C,
        External_Name => "hackrf_library_version";

   function hackrf_library_release return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/libhackrf/hackrf.h:148
   with Import => True,
        Convention => C,
        External_Name => "hackrf_library_release";

   function hackrf_get_device_list return access hackrf_device_list_t  -- /usr/local/include/libhackrf/hackrf.h:150
   with Import => True,
        Convention => C,
        External_Name => "hackrf_device_list";

   function hackrf_device_list_open
     (list : access hackrf_device_list_t;
      idx : int;
      device : System.Address) return int  -- /usr/local/include/libhackrf/hackrf.h:151
   with Import => True,
        Convention => C,
        External_Name => "hackrf_device_list_open";

   procedure hackrf_device_list_free (list : access hackrf_device_list_t)  -- /usr/local/include/libhackrf/hackrf.h:152
   with Import => True,
        Convention => C,
        External_Name => "hackrf_device_list_free";

   function hackrf_open (device : System.Address) return int  -- /usr/local/include/libhackrf/hackrf.h:154
   with Import => True,
        Convention => C,
        External_Name => "hackrf_open";

   function hackrf_open_by_serial (desired_serial_number : Interfaces.C.Strings.chars_ptr; device : System.Address) return int  -- /usr/local/include/libhackrf/hackrf.h:155
   with Import => True,
        Convention => C,
        External_Name => "hackrf_open_by_serial";

   function hackrf_close (device : access hackrf_device) return int  -- /usr/local/include/libhackrf/hackrf.h:156
   with Import => True,
        Convention => C,
        External_Name => "hackrf_close";

   function hackrf_start_rx
     (device : access hackrf_device;
      callback : hackrf_sample_block_cb_fn;
      rx_ctx : System.Address) return int  -- /usr/local/include/libhackrf/hackrf.h:158
   with Import => True,
        Convention => C,
        External_Name => "hackrf_start_rx";

   function hackrf_stop_rx (device : access hackrf_device) return int  -- /usr/local/include/libhackrf/hackrf.h:159
   with Import => True,
        Convention => C,
        External_Name => "hackrf_stop_rx";

   function hackrf_start_tx
     (device : access hackrf_device;
      callback : hackrf_sample_block_cb_fn;
      tx_ctx : System.Address) return int  -- /usr/local/include/libhackrf/hackrf.h:161
   with Import => True,
        Convention => C,
        External_Name => "hackrf_start_tx";

   function hackrf_stop_tx (device : access hackrf_device) return int  -- /usr/local/include/libhackrf/hackrf.h:162
   with Import => True,
        Convention => C,
        External_Name => "hackrf_stop_tx";

   function hackrf_is_streaming (device : access hackrf_device) return int  -- /usr/local/include/libhackrf/hackrf.h:165
   with Import => True,
        Convention => C,
        External_Name => "hackrf_is_streaming";

   function hackrf_max2837_read
     (device : access hackrf_device;
      register_number : Interfaces.Unsigned_8;
      value : access Interfaces.Unsigned_16) return int  -- /usr/local/include/libhackrf/hackrf.h:167
   with Import => True,
        Convention => C,
        External_Name => "hackrf_max2837_read";

   function hackrf_max2837_write
     (device : access hackrf_device;
      register_number : Interfaces.Unsigned_8;
      value : Interfaces.Unsigned_16) return int  -- /usr/local/include/libhackrf/hackrf.h:168
   with Import => True,
        Convention => C,
        External_Name => "hackrf_max2837_write";

   function hackrf_si5351c_read
     (device : access hackrf_device;
      register_number : Interfaces.Unsigned_16;
      value : access Interfaces.Unsigned_16) return int  -- /usr/local/include/libhackrf/hackrf.h:170
   with Import => True,
        Convention => C,
        External_Name => "hackrf_si5351c_read";

   function hackrf_si5351c_write
     (device : access hackrf_device;
      register_number : Interfaces.Unsigned_16;
      value : Interfaces.Unsigned_16) return int  -- /usr/local/include/libhackrf/hackrf.h:171
   with Import => True,
        Convention => C,
        External_Name => "hackrf_si5351c_write";

   function hackrf_set_baseband_filter_bandwidth (device : access hackrf_device; bandwidth_hz : Interfaces.Unsigned_32) return int  -- /usr/local/include/libhackrf/hackrf.h:173
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_baseband_filter_bandwidth";

   function hackrf_rffc5071_read
     (device : access hackrf_device;
      register_number : Interfaces.Unsigned_8;
      value : access Interfaces.Unsigned_16) return int  -- /usr/local/include/libhackrf/hackrf.h:175
   with Import => True,
        Convention => C,
        External_Name => "hackrf_rffc5071_read";

   function hackrf_rffc5071_write
     (device : access hackrf_device;
      register_number : Interfaces.Unsigned_8;
      value : Interfaces.Unsigned_16) return int  -- /usr/local/include/libhackrf/hackrf.h:176
   with Import => True,
        Convention => C,
        External_Name => "hackrf_rffc5071_write";

   function hackrf_spiflash_erase (device : access hackrf_device) return int  -- /usr/local/include/libhackrf/hackrf.h:178
   with Import => True,
        Convention => C,
        External_Name => "hackrf_spiflash_erase";

   function hackrf_spiflash_write
     (device : access hackrf_device;
      address : Interfaces.Unsigned_32;
      length : Interfaces.Unsigned_16;
      data : access unsigned_char) return int  -- /usr/local/include/libhackrf/hackrf.h:179
   with Import => True,
        Convention => C,
        External_Name => "hackrf_spiflash_write";

   function hackrf_spiflash_read
     (device : access hackrf_device;
      address : Interfaces.Unsigned_32;
      length : Interfaces.Unsigned_16;
      data : access unsigned_char) return int  -- /usr/local/include/libhackrf/hackrf.h:180
   with Import => True,
        Convention => C,
        External_Name => "hackrf_spiflash_read";

   function hackrf_spiflash_status (device : access hackrf_device; data : access Interfaces.Unsigned_8) return int  -- /usr/local/include/libhackrf/hackrf.h:181
   with Import => True,
        Convention => C,
        External_Name => "hackrf_spiflash_status";

   function hackrf_spiflash_clear_status (device : access hackrf_device) return int  -- /usr/local/include/libhackrf/hackrf.h:182
   with Import => True,
        Convention => C,
        External_Name => "hackrf_spiflash_clear_status";

   function hackrf_cpld_write
     (device : access hackrf_device;
      data : access unsigned_char;
      total_length : unsigned) return int  -- /usr/local/include/libhackrf/hackrf.h:185
   with Import => True,
        Convention => C,
        External_Name => "hackrf_cpld_write";

   function hackrf_board_id_read (device : access hackrf_device; value : access Interfaces.Unsigned_8) return int  -- /usr/local/include/libhackrf/hackrf.h:188
   with Import => True,
        Convention => C,
        External_Name => "hackrf_board_id_read";

   function hackrf_version_string_read
     (device : access hackrf_device;
      version : Interfaces.C.Strings.chars_ptr;
      length : Interfaces.Unsigned_8) return int  -- /usr/local/include/libhackrf/hackrf.h:189
   with Import => True,
        Convention => C,
        External_Name => "hackrf_version_string_read";

   function hackrf_usb_api_version_read (device : access hackrf_device; version : access Interfaces.Unsigned_16) return int  -- /usr/local/include/libhackrf/hackrf.h:190
   with Import => True,
        Convention => C,
        External_Name => "hackrf_usb_api_version_read";

   function hackrf_set_freq (device : access hackrf_device; freq_hz : Interfaces.Unsigned_64) return int  -- /usr/local/include/libhackrf/hackrf.h:192
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_freq";

   function hackrf_set_freq_explicit
     (device : access hackrf_device;
      if_freq_hz : Interfaces.Unsigned_64;
      lo_freq_hz : Interfaces.Unsigned_64;
      path : rf_path_filter) return int  -- /usr/local/include/libhackrf/hackrf.h:193
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_freq_explicit";

   function hackrf_set_sample_rate_manual
     (device : access hackrf_device;
      freq_hz : Interfaces.Unsigned_32;
      divider : Interfaces.Unsigned_32) return int  -- /usr/local/include/libhackrf/hackrf.h:198
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_sample_rate_manual";

   function hackrf_set_sample_rate (device : access hackrf_device; freq_hz : double) return int  -- /usr/local/include/libhackrf/hackrf.h:199
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_sample_rate";

   function hackrf_set_amp_enable (device : access hackrf_device; value : Interfaces.Unsigned_8) return int  -- /usr/local/include/libhackrf/hackrf.h:202
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_amp_enable";

   function hackrf_board_partid_serialno_read (device : access hackrf_device; read_partid_serialno : access read_partid_serialno_t) return int  -- /usr/local/include/libhackrf/hackrf.h:204
   with Import => True,
        Convention => C,
        External_Name => "hackrf_board_partid_serialno_read";

   function hackrf_set_lna_gain (device : access hackrf_device; value : Interfaces.Unsigned_32) return int  -- /usr/local/include/libhackrf/hackrf.h:207
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_lna_gain";

   function hackrf_set_vga_gain (device : access hackrf_device; value : Interfaces.Unsigned_32) return int  -- /usr/local/include/libhackrf/hackrf.h:210
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_vga_gain";

   function hackrf_set_txvga_gain (device : access hackrf_device; value : Interfaces.Unsigned_32) return int  -- /usr/local/include/libhackrf/hackrf.h:213
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_txvga_gain";

   function hackrf_set_antenna_enable (device : access hackrf_device; value : Interfaces.Unsigned_8) return int  -- /usr/local/include/libhackrf/hackrf.h:216
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_antenna_enable";

   function hackrf_error_name (errcode : hackrf_error) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/libhackrf/hackrf.h:218
   with Import => True,
        Convention => C,
        External_Name => "hackrf_error_name";

   function hackrf_board_id_name (board_id : hackrf_board_id) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/libhackrf/hackrf.h:219
   with Import => True,
        Convention => C,
        External_Name => "hackrf_board_id_name";

   function hackrf_usb_board_id_name (usb_board_id : hackrf_usb_board_id) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/libhackrf/hackrf.h:220
   with Import => True,
        Convention => C,
        External_Name => "hackrf_usb_board_id_name";

   function hackrf_filter_path_name (path : rf_path_filter) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/libhackrf/hackrf.h:221
   with Import => True,
        Convention => C,
        External_Name => "hackrf_filter_path_name";

   function hackrf_compute_baseband_filter_bw_round_down_lt (bandwidth_hz : Interfaces.Unsigned_32) return Interfaces.Unsigned_32  -- /usr/local/include/libhackrf/hackrf.h:224
   with Import => True,
        Convention => C,
        External_Name => "hackrf_compute_baseband_filter_bw_round_down_lt";

   function hackrf_compute_baseband_filter_bw (bandwidth_hz : Interfaces.Unsigned_32) return Interfaces.Unsigned_32  -- /usr/local/include/libhackrf/hackrf.h:226
   with Import => True,
        Convention => C,
        External_Name => "hackrf_compute_baseband_filter_bw";

   function hackrf_set_hw_sync_mode (device : access hackrf_device; value : Interfaces.Unsigned_8) return int  -- /usr/local/include/libhackrf/hackrf.h:231
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_hw_sync_mode";

   function hackrf_init_sweep
     (device : access hackrf_device;
      frequency_list : access Interfaces.Unsigned_16;
      num_ranges : int;
      num_bytes : Interfaces.Unsigned_32;
      step_width : Interfaces.Unsigned_32;
      offset : Interfaces.Unsigned_32;
      style : sweep_style) return int  -- /usr/local/include/libhackrf/hackrf.h:234
   with Import => True,
        Convention => C,
        External_Name => "hackrf_init_sweep";

   function hackrf_get_operacake_boards (device : access hackrf_device; boards : access Interfaces.Unsigned_8) return int  -- /usr/local/include/libhackrf/hackrf.h:240
   with Import => True,
        Convention => C,
        External_Name => "hackrf_get_operacake_boards";

   function hackrf_set_operacake_ports
     (device : access hackrf_device;
      address : Interfaces.Unsigned_8;
      port_a : Interfaces.Unsigned_8;
      port_b : Interfaces.Unsigned_8) return int  -- /usr/local/include/libhackrf/hackrf.h:241
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_operacake_ports";

   function hackrf_reset (device : access hackrf_device) return int  -- /usr/local/include/libhackrf/hackrf.h:246
   with Import => True,
        Convention => C,
        External_Name => "hackrf_reset";

   function hackrf_set_operacake_ranges
     (device : access hackrf_device;
      ranges : access Interfaces.Unsigned_8;
      num_ranges : Interfaces.Unsigned_8) return int  -- /usr/local/include/libhackrf/hackrf.h:248
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_operacake_ranges";

   function hackrf_set_clkout_enable (device : access hackrf_device; value : Interfaces.Unsigned_8) return int  -- /usr/local/include/libhackrf/hackrf.h:252
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_clkout_enable";

   function hackrf_operacake_gpio_test
     (device : access hackrf_device;
      address : Interfaces.Unsigned_8;
      test_result : access Interfaces.Unsigned_16) return int  -- /usr/local/include/libhackrf/hackrf.h:254
   with Import => True,
        Convention => C,
        External_Name => "hackrf_operacake_gpio_test";

   function hackrf_set_ui_enable (device : access hackrf_device; value : Interfaces.Unsigned_8) return int  -- /usr/local/include/libhackrf/hackrf.h:262
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_ui_enable";

   function hackrf_start_rx_sweep
     (device : access hackrf_device;
      callback : hackrf_sample_block_cb_fn;
      rx_ctx : System.Address) return int  -- /usr/local/include/libhackrf/hackrf.h:263
   with Import => True,
        Convention => C,
        External_Name => "hackrf_start_rx_sweep";

end libhackrf;
