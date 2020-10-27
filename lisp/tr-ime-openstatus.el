;;; tr-ime-openstatus.el --- IME openstatus functions -*- lexical-binding: t -*-

;; Copyright (C) 2020 Masamichi Hosoda

;; Author: Masamichi Hosoda <trueroad@trueroad.jp>
;; URL: https://github.com/trueroad/tr-emacs-ime-module
;; Version: 0.3.50
;; Package-Requires: ((emacs "27.1"))

;; Emulator of GNU Emacs IME patch for Windows (tr-ime)
;; is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; Emulator of GNU Emacs IME patch for Windows (tr-ime)
;; is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with tr-ime.
;; If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This file is part of
;; Emulator of GNU Emacs IME patch for Windows (tr-ime).
;; See tr-ime.el

;;; Code:

;;
;; ユーザ設定用
;;

(defgroup tr-ime nil
  "Emulator of GNU Emacs IME patch for Windows (tr-ime)"
  :group 'emacs)

(defgroup tr-ime-core nil
  "コア機能設定

コア機能の設定です。通常は設定変更しないでください。"
  :group 'tr-ime)

(defgroup tr-ime-openstatus nil
  "IME 状態変更・状態取得"
  :group 'tr-ime-core)

;;
;; Emacs 28 standard
;;

(defcustom tr-ime-openstatus-emacs28-open-check-counter 3
  "GNU Emacs 28 の IME 状態変更関数使用後の状態確認回数上限 (standard).

GNU Emacs 28 で standard の場合は
IME 状態変更関数 w32-set-ime-open-status を使うが、
これを呼んだ直後に IME 状態確認関数 w32-get-ime-open-status を呼んでも、
状態変更前を示す返り値が得られることがある。
そこで、ここで設定した回数を上限として状態変更が完了するまで確認する。
デフォルト値の 3 であれば最大で 3 回確認するが、
1 回目や 2 回目で完了していたらそこで打ち切る。
0 を設定した場合は一切完了確認しない。"
  :type 'integer
  :group 'tr-ime-openstatus)

(declare-function w32-set-ime-open-status "w32fns.c" status) ; Emacs 28
(declare-function w32-get-ime-open-status "w32fns.c") ; Emacs 28

(defun tr-ime-openstatus--force-on-emacs28 (&optional _dummy)
  "GNU Emacs 28 standard 向け ime-force-on 実装.

GNU Emacs 28 の w32-set-ime-open-status で
IME パッチの ime-force-on をエミュレーションする。
IME が on になる。"
  (w32-set-ime-open-status t)
  (let ((counter 0))
    (while
        (and (< counter tr-ime-openstatus-emacs28-open-check-counter)
             (not (w32-get-ime-open-status)))
      (setq counter (1+ counter)))))

(defun tr-ime-openstatus--force-off-emacs28 (&optional _dummy)
  "GNU Emacs 28 standard 向け ime-force-off 実装.

GNU Emacs 28 の w32-set-ime-open-status で
IME パッチの ime-force-off をエミュレーションする。
IME が off になる。"
  (w32-set-ime-open-status nil)
  (let ((counter 0))
    (while
        (and (< counter tr-ime-openstatus-emacs28-open-check-counter)
             (w32-get-ime-open-status))
      (setq counter (1+ counter)))))

;;
;; Emacs 27 standard
;;

(declare-function tr-ime-mod--setopenstatus "tr-ime-mod"
                  arg1 arg2)
(declare-function tr-ime-mod--getopenstatus "tr-ime-mod"
                  arg1)

(defun tr-ime-openstatus--get-mode-emacs27 ()
  "GNU Emacs 27 standard 向け ime-get-mode 実装.

C 実装モジュールで IME パッチの ime-get-mode をエミュレーションする。
IME が OFF なら nil を、ON ならそれ以外を返す。"
  (tr-ime-mod--getopenstatus
   (string-to-number (frame-parameter nil 'window-id))))

(defun tr-ime-openstatus--force-on-emacs27 (&optional _dummy)
  "GNU Emacs 27 standard 向け ime-force-on 実装.

C 実装モジュールで IME パッチの ime-force-on をエミュレーションする。
IME が on になる。"
  (tr-ime-mod--setopenstatus
   (string-to-number (frame-parameter nil 'window-id)) t))

(defun tr-ime-openstatus--force-off-emacs27 (&optional _dummy)
  "GNU Emacs 27 standard 向け ime-force-off 実装.

C 実装モジュールで IME パッチの ime-force-off をエミュレーションする。
IME が off になる。"
  (tr-ime-mod--setopenstatus
   (string-to-number (frame-parameter nil 'window-id)) nil))

;;
;; advanced
;;

(declare-function tr-ime-modadv--setopenstatus "tr-ime-modadv"
                  arg1 arg2)
(declare-function tr-ime-modadv--getopenstatus "tr-ime-modadv"
                  arg1)

(defun tr-ime-openstatus--get-mode-advanced ()
  "Advanced 向け ime-get-mode 実装.

C++ 実装モジュールで IME パッチの ime-get-mode をエミュレーションする。
IME が off なら nil を、on ならそれ以外を返す。
メッセージフックおよびサブクラス化が有効である必要がある。"
  (tr-ime-modadv--getopenstatus
   (string-to-number (frame-parameter nil 'window-id))))

(defun tr-ime-openstatus--force-on-advanced (&optional _dummy)
  "Advanced 向け ime-force-on 実装.

C++ 実装モジュールで IME パッチの ime-force-on をエミュレーションする。
IME が on になる。
メッセージフックおよびサブクラス化が有効である必要がある。"
  (tr-ime-modadv--setopenstatus
   (string-to-number (frame-parameter nil 'window-id)) t))

(defun tr-ime-openstatus--force-off-advanced (&optional _dummy)
  "Advanced 向け ime-force-off 実装.

C++ 実装モジュールで IME パッチの ime-force-off をエミュレーションする。
IME が off になる。
メッセージフックおよびサブクラス化が有効である必要がある。"
  (tr-ime-modadv--setopenstatus
   (string-to-number (frame-parameter nil 'window-id)) nil))

;;
;; define aliases
;;

(defalias 'tr-ime-openstatus-get-mode
  (cond
   ((featurep 'tr-ime-modadv)
    #'tr-ime-openstatus--get-mode-advanced)
   ((fboundp #'w32-get-ime-open-status)
    #'w32-get-ime-open-status)
   (t
    #'tr-ime-openstatus--get-mode-emacs27))
  "IME 状態を返す関数

IME パッチの ime-get-mode 互換。
IME が OFF なら nil を、ON ならそれ以外を返す。")

(defalias 'tr-ime-openstatus-force-on
  (cond
   ((featurep 'tr-ime-modadv)
    #'tr-ime-openstatus--force-on-advanced)
   ((fboundp #'w32-set-ime-open-status)
    #'tr-ime-openstatus--force-on-emacs28)
   (t
    #'tr-ime-openstatus--force-on-emacs27))
  "IME を on にする関数

IME パッチの ime-force-on 互換。")

(defalias 'tr-ime-openstatus-force-off
  (cond
   ((featurep 'tr-ime-modadv)
    #'tr-ime-openstatus--force-off-advanced)
   ((fboundp #'w32-set-ime-open-status)
    #'tr-ime-openstatus--force-off-emacs28)
   (t
    #'tr-ime-openstatus--force-off-emacs27))
  "IME を off にする関数

IME パッチの ime-force-on 互換。")

;;
;; define obsolete functions
;;

(define-obsolete-function-alias 'ime-get-mode
  #'tr-ime-openstatus-get-mode "2020")

(define-obsolete-function-alias 'ime-force-on
  #'tr-ime-openstatus-force-on "2020")

(define-obsolete-function-alias 'ime-force-off
  #'tr-ime-openstatus-force-off "2020")

;;
;; provide
;;

(provide 'tr-ime-openstatus)

;; Local Variables:
;; coding: utf-8
;; End:

;;; tr-ime-openstatus.el ends here
