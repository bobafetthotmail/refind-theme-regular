# Super rEFInd

A simplistic clean and minimal theme for rEFInd, ready to go for mac.

![screenshot][screenshot]

### Usage

1. Mount your EFI directory:

   - `sudo mkdir /Volumes/efi`
   - `sudo mount -t msdos /dev/disk0s1 /Volumes/efi`
   - `open /Volumes/efi/`

2. Locate refind and create a folder called `themes` inside it.

3. Clone this repository into the `themes` directory.

4. To enable the theme add `include themes/super-refind/theme.conf` at the end of `refind/refind.conf`.

**More information**

The official [rEFInd website][refind-website].

### Attribution

- [munlik][refind-theme-original], the initial creator.
- [bobafetthotmail][refind-theme-regular], continuing the work of munlik

The background is [Minimalist Wallpaper][wallpaper] by
[LeonardoAIanB][wallpaper-author].

[screenshot]: /screenshot.jpg
[refind-website]: https://www.rodsbooks.com/refind/
[refind-theme-original]: https://github.com/munlik/refind-theme-regular
[refind-theme-regular]: https://github.com/bobafetthotmail/refind-theme-regular
[wallpaper]: https://leonardoalanb.deviantart.com/art/Minimalist-wallpaper-295519786
[wallpaper-author]: https://leonardoalanb.deviantart.com/
