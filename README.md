# Arch Linux環境構築メモ

## 目指すゴール
Arch Linuxを開発環境として使用できるようにする。

## 前提
1. Linuxは仮想マシンで動作させる<br/>
    Linux初心者にPC丸ごとLinux化はハードルが高かったのでやり直せる仮想マシンを選択

1. セキュリティは最低限<br />
    複雑なセキュリティはめんｄ…難しいので最低限のファイアーウォールを構築する

## 事前準備
1. VirtualBoxのインストール<br />
    [ココ](https://www.virtualbox.org/)からVirtualBoxのインストーラを入手してインストール。<br />
    あと本体だけでなくExtension Packも一緒にダウンロードすること。(Macだと不要？)<br />
    これがないとLinuxを動かせないので注意。本体のインストールが終了したらVirtualBoxを起動し、環境設定→機能拡張で先ほどダウンロードしたExtension Packをインストールする。

1. Arch Linux ISOの入手<br />
    Arch Linuxの[Download](https://www.archlinux.org/download/)から適当なミラーを選択してISOを入手する。(基本的にはx86_64版)

1. BIOS設定の変更<br />
    割と忘れがちになるが、64bit OSを使用したい場合はBIOSのVirtualization TechnologyをEnabledに変更する必要がある。<br />
    Virtual Boxで64bitが選択できない場合は、コイツのせい。

## Virtual Boxの設定
Linuxをインストールする前にまずはVirtual Boxに諸々の設定を行うこと必要がある。<br />
以下の作業はVirtual Box GUIを起動して行う。

1. 仮想マシンの追加<br />
    メニューの新規(Ctl+N)を押下して仮想マシンの追加ダイアログを表示する。<br />
    ダイアログが表示されたら以下のような感じで設定をする。（ちなみにエキスパートモード）<br />

    1. 名前：適当な名前(Archなどと入力するとタイプとバージョンが自動的に設定されるので便利)
    1. タイプ：Arch Linux
    1. バージョン：64bit
    1. メモリサイズ：お好きにどうぞ（総メモリの半分くらいでもOK）
    1. ハードディスク：デフォルトでよい
    1. ファイルの場所：デフォルトでよい
    1. ファイルサイズ：お好きにどうぞ(最低50Gくらい？)
    1. HDのファイルタイプ：VDI
    1. 物理HDにあるストレージ：可変サイズ

1. 仮想マシンの設定<br />
    追加されたマシンの各種設定を行う。

    1. 一般→高度
        1. クリップボードの共有：双方向
        1. D&D：双方向
    1. システム→マザーボード<br />
        EFIを有効化にチェック。(UEFIで構築する場合のみ。ただし最近のBIOSはUIFIが標準のようなのでデフォ認識で良い気がする)
    1. システム→プロセッサー<br />
        プロセッサー数を変更(緑全部で良い気がする)
    1. ディスプレイ→スクリーン<br />
        1. ビデオメモリ:MAX
        1. アクセラレーション：3Dアクセラレーションにチェック
    1. ストレージ<br />
        コントローラの空を選択し、属性：光学ドライブにダウンロードしたISOを設定
    1. 共有フォルダ<br />
        おまかせ。使用するならそのフォルダを追加し、自動マウントにチェックをつける。

これでVirtual Boxの設定は終了。仮想マシンを起動したらインストール作業に移れる。

## インストール
大体Archの[ビギナーズガイド](https://wiki.archlinuxjp.org/index.php/%E3%83%93%E3%82%AE%E3%83%8A%E3%83%BC%E3%82%BA%E3%82%AC%E3%82%A4%E3%83%89)や[インストールガイド](https://wiki.archlinuxjp.org/index.php/%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB%E3%82%AC%E3%82%A4%E3%83%89)通りにやれば良い。

構築時には他に以下のサイトも参考にした。
* [普段遣いのArchLinux](http://archlinux-blogger.blogspot.jp/p/blog-page.html)
* [クロの思考ノート](http://note.kurodigi.com/category/arch-linux/)


### _インストールからGUI構築前まで_
仮想マシンを起動して放置しておくといつの間にかroot画面が出ているので以下の要領でインストール作業を行う。
1. キーボードレイアウトの変更<br />
    `loadkeys jp106`と打ち込むことでキーボードレイアウトを日本語レイアウトに変更する。<br />
    英語キーボードの場合は不要。
1. パーティションの作成<br />
  `gdisk /dev/sdX`と打ち込んでパーティション編集アプリを起動する。<br />
  仮想マシンの場合は`sdX`の部分は`sda`で良い。<br />
  パーティションはboot, root, var, homeを作成するが、varの作成は任意のよう。

    1. コマンド入力：o → y<br />
        領域の初期化？を行う。
    1. コマンド入力：n(新規パーティションの作成)
    1. Partition Number:(Enter)
    1. First sector:(Enter)
    1. Last Sector:(boot:+512MiB, root:+20GiB, var:+8GiB, home:Enter)
    1. Hex code or GUID:(boot:ef00, other:Enter)
    1. コマンド入力：c → Partition Numberでパーティション名を設定する。

1. パーティションのフォーマット<br />
  bootのみFATでフォーマットし、あとのパーティションはXFSでフォーマットを行う。<br />
  例）<br />
  `mkfs.vfat -F32 /dev/sdXM && mkfs.xfs -m crc=1 /dev/sdXN && mkfs.xfs -m crc=1 /dev/sdXO && mkfs.xfs -m crc=1 /dev/sdXP`
1. マウント<br />
