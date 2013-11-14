Deface::Override.new(virtual_path:  'spree/admin/promotions/index',
                     name:          'promotions_import_vouchers_link',
                     insert_before: "li:first",
                     text:          "<li><%= button_link_to 'Import Voucher Codes', spree.new_admin_voucher_path, icon: 'icon-upload' %>&nbsp;</li>")
