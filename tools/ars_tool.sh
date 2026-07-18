#!/data/data/com.termux/files/usr/bin/bash

# الألوان
GREEN='\033[0;32m'; CYAN='\033[0;36m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; PURPLE='\033[0;35m'; RESET='\033[0m'

# القائمة الرئيسية
clear
echo -e "${PURPLE}==================================================${RESET}"
echo -e "${CYAN}        _    ____  ____  ${RESET}"
echo -e "${CYAN}       / \  |  _ \/ ___| ${RESET}"
echo -e "${CYAN}      / _ \ | |_) \___ \ ${RESET}"
echo -e "${CYAN}     / ___ \|  _ < ___) |${RESET}"
echo -e "${CYAN}    /_/   \_\_| \_\____/ ${RESET}"
echo -e ""
echo -e "${GREEN}      ARS Manga/Manhwa Downloader & Editor${RESET}"
echo -e "${YELLOW}   All Rights Reserved ARS | Insta: @s.4ps${RESET}"
echo -e "${PURPLE}==================================================${RESET}"
echo -e "${CYAN}[1]${RESET} Download & Split Chapter (IbisPaint Mode)"
echo -e "${CYAN}[2]${RESET} Download & Merge to PDF"
echo -e "${CYAN}[3]${RESET} Merge Manual Pieces to PDF"
echo -e "${RED}[4]${RESET} Exit"
echo -e "${PURPLE}==================================================${RESET}"
echo -n -e "${YELLOW}Choose an option [1-4]: ${RESET}"
read choice

if [[ "$choice" =~ ^[1-2]$ ]]; then
    echo -n -e "${CYAN}Manga Name: ${RESET}"; read manga_name
    echo -n -e "${CYAN}Chapter Number: ${RESET}"; read ch_num
    echo -n -e "${CYAN}Chapter URL: ${RESET}"; read ch_url

    TARGET_DIR="/sdcard/Download/الفصول_المحرره/${manga_name}/Chapter_${ch_num}"
    mkdir -p "$TARGET_DIR"; cd "$TARGET_DIR"

    echo -e "${YELLOW}[*] Initializing extraction engine...${RESET}"

    # إنشاء سكربت الاستخراج داخلياً
    cat << 'NODE' > .temp_scraper.js
const puppeteer = require('puppeteer-core');
const fs = require('fs');
(async () => {
  const browser = await puppeteer.launch({ executablePath: '/data/data/com.termux/files/usr/bin/chromium-browser', args: ['--no-sandbox'] });
  const page = await browser.newPage();
  await page.goto(process.argv[2], { waitUntil: 'networkidle2', timeout: 90000 });
  await page.evaluate(async () => {
    for(let i=0; i<100; i++){ window.scrollBy(0, 500); await new Promise(r => setTimeout(r, 100)); }
  });
  const links = await page.evaluate(() => Array.from(document.querySelectorAll('img')).map(i => i.src).filter(s => s.match(/\.(jpg|jpeg|png|webp)/i)));
  fs.writeFileSync('links.txt', [...new Set(links)].join('\n'));
  await browser.close();
})();
NODE

    node .temp_scraper.js "$ch_url"
    
    # التحميل
    count=1
    total=$(wc -l < links.txt)
    while read -r link; do
        printf "\r${YELLOW}[*] Fetching [%d/%d]...${RESET}" "$count" "$total"
        curl -s -L "$link" -o "$(printf "%03d" $count).jpg"
        ((count++))
    done < links.txt

    # المعالجة
    if [ "$choice" -eq 1 ]; then
        magick convert [0-9]*.jpg -quality 100 -crop 100%x4000+0+0@ +repage split_%03d.jpg
    else
        magick convert [0-9]*.jpg "Chapter_${ch_num}_Merged.pdf"
    fi
    rm -f [0-9]*.jpg links.txt .temp_scraper.js
    echo -e "\n${GREEN}[✓] Done! Path: ${TARGET_DIR}${RESET}"

elif [ "$choice" -eq 3 ]; then
    echo -n -e "${CYAN}Enter path: ${RESET}"; read custom_path
    cd "$custom_path"; magick convert split_*.jpg Final_Merge.pdf
    echo -e "${GREEN}[✓] PDF generated.${RESET}"
else
    echo -e "${RED}Exited.${RESET}"
fi
