.PHONY: clean


bootia32.efi:
	grub-mkstandalone -v \
	    -d /usr/lib/grub/i386-efi/ \
	    -O i386-efi \
	    --modules='part_gpt part_msdos' \
	    --fonts=unicode \
	    --locales=uk \
	    --themes='' \
	    -o ./bootia32.efi \
	    /boot/grub/grub.cfg=./grub.cfg


clean:
	rm -fv bootia32.efi
