BITS 16
ORG 0x8000

%include "../stage2/config.asm"
%include "../stage2/entry_loop.asm"
%include "../stage2/gameplay.asm"
%include "../stage2/render.asm"
%include "../stage2/title.asm"
%include "../stage2/ui.asm"
%include "../stage2/utils.asm"
%include "../stage2/data.asm"

times 4096-($-$$) db 0
