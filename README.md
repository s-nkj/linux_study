# Arch Linux環境構築メモ

## 目指すゴール
Arch Linuxを開発環境として使用できるようにする。

## 前提
1. Linuxは仮想マシンで動作させる<br/>
    Linux初心者にPC丸ごとLinux化はハードルが高かったのでやり直せる仮想マシンを選択。

1. セキュリティは最低限  
    複雑なセキュリティはめんｄ…難しいので最低限のファイアーウォールを構築する。

1. パーティションはGPT/UEFIで構築する  
    GPT/BIOSの設定ではないので注意。  
    何故GPT/UEFIを前提とするかというとそれが現在では標準だと考えらえるから。

## 事前準備
1. VirtualBoxのインストール  
    [ココ](https://www.virtualbox.org/)からVirtualBoxのインストーラを入手してインストール。  
    あと本体だけでなくExtension Packも一緒にダウンロードすること。(Macだと不要？)  
    これがないとLinuxを動かせないので注意。本体のインストールが終了したらVirtualBoxを起動し、環境設定→機能拡張で先ほどダウンロードしたExtension Packをインストールする。

1. Arch Linux ISOの入手  
    Arch Linuxの[Download](https://www.archlinux.org/download/)から適当なミラーを選択してISOを入手する。(基本的にはx86_64版)

1. BIOS設定の変更  
    割と忘れがちになるが、64bit OSを使用したい場合はBIOSのVirtualization TechnologyをEnabledに変更する必要がある。(BIOSによって項目名が違う可能性あり)  
    Virtual Boxで64bitが選択できない場合は、コイツのせい。

## Virtual Boxの設定
Linuxをインストールする前にまずはVirtual Boxに諸々の設定を行うこと必要がある。  
以下の作業はVirtual Box GUIを起動して行う。

1. 仮想マシンの追加  
    メニューの新規(Ctl+N)を押下して仮想マシンの追加ダイアログを表示する。  
    ダイアログが表示されたら以下のような感じで設定をする。（ちなみにエキスパートモード）  

    1. 名前：適当な名前(Archなどと入力するとタイプとバージョンが自動的に設定されるので便利)
    1. タイプ：Arch Linux
    1. バージョン：64bit
    1. メモリサイズ：お好きにどうぞ（総メモリの半分くらいでもOK）
    1. ハードディスク：デフォルトでよい
    1. ファイルの場所：デフォルトでよい
    1. ファイルサイズ：お好きにどうぞ(最低50Gくらい？)
    1. HDのファイルタイプ：VDI
    1. 物理HDにあるストレージ：可変サイズ

1. 仮想マシンの設定  
    追加されたマシンの各種設定を行う。

    1. 一般→高度
        1. クリップボードの共有：双方向
        1. D&D：双方向
    1. システム→マザーボード  
        EFIを有効化にチェック。(UEFIで構築する場合のみ。ただし最近のBIOSはUIFIが標準のようなのでデフォ認識で良い気がする)
    1. システム→プロセッサー  
        プロセッサー数を変更(緑全部で良い気がする)
    1. ディスプレイ→スクリーン  
        1. ビデオメモリ:MAX
        1. アクセラレーション：3Dアクセラレーションにチェック
    1. ストレージ  
        コントローラの空を選択し、属性：光学ドライブにダウンロードしたISOを設定
    1. 共有フォルダ  
        おまかせ。使用するならそのフォルダを追加し、自動マウントにチェックをつける。

これでVirtual Boxの設定は終了。仮想マシンを起動したらインストール作業に移れる。

## インストール
大体Archの[ビギナーズガイド](https://wiki.archlinuxjp.org/index.php/%E3%83%93%E3%82%AE%E3%83%8A%E3%83%BC%E3%82%BA%E3%82%AC%E3%82%A4%E3%83%89)や[インストールガイド](https://wiki.archlinuxjp.org/index.php/%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB%E3%82%AC%E3%82%A4%E3%83%89)通りにやれば良い。

構築時には他に以下のサイトも参考にした。
* [普段遣いのArchLinux](http://archlinux-blogger.blogspot.jp/p/blog-page.html)
* [クロの思考ノート](http://note.kurodigi.com/category/arch-linux/)


### _Linuxの環境構築（GUI構築前まで）_
仮想マシンを起動して放置しておくといつの間にかroot画面が出ているので以下の要領でインストール作業を行う。

1. キーボードレイアウトの変更  
    `loadkeys jp106`と打ち込むことでキーボードレイアウトを日本語レイアウトに変更する。  
    英語キーボードの場合は不要。

1. パーティションの作成  
    `gdisk /dev/sdX`と打ち込んでパーティション編集アプリを起動する。  
    仮想マシンの場合は`sdX`の部分は`sda`で良い。  
    パーティションはboot, root, var, homeを作成するが、varの作成は任意のよう。

    1. コマンド入力：o → y  
        領域の初期化？を行う。
    1. コマンド入力：n(新規パーティションの作成)
    1. Partition Number:(Enter)
    1. First sector:(Enter)
    1. Last Sector:(boot:+512MiB, root:+20GiB, var:+8GiB, home:Enter)
    1. Hex code or GUID:(boot:ef00, other:Enter)
    1. コマンド入力：c → Partition Numberでパーティション名を設定する。

1. パーティションのフォーマット  
    bootのみFATでフォーマットし、あとのパーティションはXFSでフォーマットを行う。  
    e.g.)  
    `mkfs.vfat -F32 /dev/sdXM && mkfs.xfs -m crc=1 /dev/sdXN && mkfs.xfs -m crc=1 /dev/sdXO && mkfs.xfs -m crc=1 /dev/sdXP`

1. マウント  
    パーティションのマウントを実施する。マウント先のディレクトリに関してはマウント直前に作成しても良いし、最初に纏めて作ってしまっても良い。  (実行前後にlsblk /dev/sdXと打つと確認がしやすいかも)  
    1. rootのマウント  
      コマンドは`mount /dev/sdXN /mnt`  
      root( / )パーティションのマウントを実施する。これを一番最初に実施しないと、後のディレクトリの作成が出来ない。
    1. 各ディレクトリの作成  
      コマンドは`mkdir -p /mnt/boot && mkdir -p /mnt/var && mkdir -p /mnt/home`
    1. 各ディレクトリへのマウント
      コマンドは`mount /dev/sdXM /mnt/boot && mount /dev/sdXO /mnt/var && mount /dev/sdXP /mnt/home`

1. pacmanのミラーリスト修正  
    Arch Linuxをインストールする際にArchが持つパッケージマネージャ pacmanを利用するがデフォルトのミラーリストを使用すると海外サーバーを見に行くので国内のサーバーを上にもってくる必要がある。  
    国内サーバーとしてはJAIST(北陸先端技術大学院大学)と筑波があるが、筑波は最近繋がりが悪いのでJAISTのみを上に持って来れば良い。  

    `vi /etc/pacman.d/mirrorlist`→`/Japan`→`j`→`dd`→`6G`→`p`と打ち込めば良い。

1. Arch Linuxの構築  
    下記のコマンドを実行することで自身のストレージないにArchをインストールすることが出来る。  
    そこそこ時間が掛かるのでコーヒーでも飲んで時間を潰すと良い。  
    `pacstrap /mnt base base-devel`

1. fstabの生成  
    `genfstab -U -p /mnt >> /mnt/etc/fstab`

    note) fstabとはファイルのマウントポイントなどが記載されているファイル。boot時にこの設定でファイルシステムをマウントするらしい。取り敢えず一度作れば良いものらしい。むしろ一度生成した後にもう一度実行したりはしない方がいいっぽい。

1. 各種設定  
    以降は/mntにchrootして作業を行う。  
    `arch-chroot /mnt /bin/bash`

    1. rootパスワードの設定(root権限の別ユーザを作成する場合は不要かも)  
        `passwd`と打ち込んでrootのパスワードの設定を行う。

    1. Localeの設定
        1. /etc/locale.genの修正  
            locale.genの`en_US.UTF-8`行と`ja_JP.UTF-8`行の先頭の`#`を削除する。
        1. locale-genの実行  
            locale.genでコメントアウトを外したLocaleの生成が行われる。
        1. /etc/locale.confの追加  
            `echo LANG=en_US.UTF-8 > /etc/locale.conf`
        1. 環境変数LANGの設定  
            `export LANG=en_US.UTF-8`

        ja_JP.UTF-8を設定したいところだが、日本語環境が整っていないので現時点で設定すると以降の作業でメッセージが文字化けする。  
    1. キーマップの設定  
        `echo KEYMAP=jp106 > /etc/vconsole.conf`
    1. タイムゾーンの設定  
        1. シンボリックリンクの作成  
            /etc/localtimeにシンボリックリンクを作成する。  
            `ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime`
        1. ハードウェアクロックの設定  
            `hwclock --systohc --utc`
    1. ホスト名の設定
        1. /etc/hostnameの作成  
            `echo [任意のホスト名] > /etc/hostname`
        1. hostsの編集
            `vi /etc/hosts`でhostsファイルを開き、localhostの後にスペースを空けて上記でhostnameに設定した名称を入力する。

      またIPv6を使用する予定がなければhostsの2行目(::1)はこの時点でコメントアウトしても良いと思う。  
    1. ネットワークサービスの有効化  
        先ずは`ip link`と打ち込んで現在のネットワーク接続に使用されているサービス一覧を表示する。  
        表示された中からetherと表示されている接続を探し、Numberの横に表示されているのがサービス名になる。  
        e.g.)  `1: lo: <LOOPBACK,UP,LOWER_UP>`と表示されていればloがサービス名

        サービス名が判明したら以下のコマンドでサービスを有効化する。  
        `systemctl enable dhcpcd@[サービス名].service`
    1. pacman関連の修正  
        /etc/pacman.confの修正を行い、pacmanからダウンロード可能なカテゴリを追加する。
        まずは`vi /etc/pacman.conf`でpacman.confの内容をviエディタで表示する。  

        1. 32bitアプリケーションを使いたい場合  
            [multilib]とその直下にある記述のコメントアウトを解除する。
        1. 非公式リポジトリを使うための準備  
            以下の記述をpacman.confの最後に記述する。  
            ```
            [archlinuxfr]
            SigLevel = Never
            Server = http://repo.archlinux.fr/$arch
            ```
        1. ローカルリポジトリとリモートリポジトリの同期  
            `pacman -Syy`
    1. ブートローダのインストール  
      1. CPUがintelの場合のみ  
          `pacman -S intel-ucode`  
          note) Intelのマイクロコードのアップデートを有効にするために上記パッケージをインストールする必要がある。
      1. 必要なパッケージのインストール  
          `pacman -S dosfstools efibootmgr grug`  
          + dosfstools : EFI System Partitionを操作する為に必要
          + efibootmgr : .efiブータブルスタブを作成する為に必要
          + grub : ブートローダ
      1. ブートローダのインストール  
          `grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch_grub --recheck`
      1. ブータブルスタブの作成
          ```
          mkdir -p /boot/EFI/boot
          cp /boot/EFI/arch_grub/grubx64.efi /boot/EFI/boot/bootx64.efi
          ```
      1. コンフィグの生成  
          `grub-mkconfig -o /boot/grub/grub.cfg`
    1. 他ツールをインストール
        この手順はArch Linuxのインストール手順としては不要。  
        ただ素のままだと操作がし辛かったりするので使いそうなパッケージや、必要なパッケージを前もってインストールしているだけ。  
        `pacman -S vim neovim git wget openssh reflector yaourt package-query`  
        + vim : 言わずと知れたエディタソフト。neovimを通常使うため本来は不要だが、vimtutorなどが欲しいためインストール。
        + neovim : vimのリメイク版。
        + git : git本体
        + wget : webから何かをダウンロードしてくる際に使用
        + openssh : SSHを使うために必要(鍵生成とかのツールも入ってる)
        + reflector : pacmanのミラーリストの更新ツール。  
            e.g.) `reflector --verbose -c 'United States' -c Japan -c Taiwan --sort rate -l 200 --save /etc/pacman.d/mirrorlist`  
            上のコマンドの意味は現在有効である国が「米国 or 日本 or 台湾」のサーバーを接続速度順にソートした後に200件抽出して、/etc/pacman.d/mirrorlistに保存する。
        + yaourt : 非公式リポジトリ(AUR)を使用するために必要。
        + package-query : 同上。（非公式リポジトリよりダウンロードしたパッケージのビルドに必要）
