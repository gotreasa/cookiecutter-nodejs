#!/bin/bash

function usage() {
  echo "Usage: "
  echo "  npm run commit chore                              # chore: <message>"
  echo "  npm run commit desc                               # docs: description added"
  echo "  npm run commit (p | plan | plans)                 # docs: user stories added"
  echo "  npm run commit (td | techdebt)                    # docs: updated techdebt"
  echo "  npm run commit (n | note | notes)                 # docs: updated notes"
  echo "  npm run commit uat <us> <uat> (r | red)           # feat(us<us>/uat<uat>): red"
  echo "  npm run commit uat <us> <uat> (g | green)         # feat(us<us>/uat<uat>): green"
  echo "  npm run commit uat <us> <uat> ref <message>       # refactor(us<us>/uat<uat>): <message>"
  echo "  npm run commit uat <us> <uat> (c | covered)       # test(us<us>/uat<uat>): added already covered test case"
  echo "  npm run commit uat <us> <uat> (d | done)          # feat(us<us>/uat<uat>): done"
  echo "  npm run commit us <us> done                       # feat(us<us>): done"
  exit 1
}

function checkNotEmpty() {
  if [[ -z "$1" ]]; then
    usage
    exit 1
  fi
}

function uatMessage() {
  TYPE="$1"
  US="$2"
  UAT="$3"
  MSG="$4"
  SCOPE="us$US/uat$US.$UAT"
  echo "$TYPE($SCOPE): $MSG"
}

function commit() {
  git add .
  git commit -m "$1" $2
  exit 0
}

ACTION="$1"

checkNotEmpty "$ACTION"

case "$ACTION" in

  "chore")
    MSG="$2"
    checkNotEmpty "$MSG"
    commit "chore: 🧹 $MSG"
    ;;

  "desc")
    commit "docs: 📝 added kata description"
    ;;

  "p" | "plan" | "plans")
    commit "docs: 📝 added user stories"
    ;;

  "td" | "techdebt")
    commit "docs: 📝 updated techdebt"
    ;;

  "n" | "note" | "notes")
    commit "docs: 📝 updated notes"
    ;;

  "uat")
    US="$2"
    UAT="$3"
    PHASE="$4"
    CUSTOM_MESSAGE="$5"
    MSG=""
    COMMIT_OPTS=""
    
    checkNotEmpty "$US"
    checkNotEmpty "$UAT"
    checkNotEmpty "$PHASE"

    case "$PHASE" in

      "r" | "red")
	      MSG=$(uatMessage feat "$US" "$UAT" "🔴 red")
        ;;

      "g" | "green")
        MSG=$(uatMessage feat "$US" "$UAT" "🟢 green")
        ;;

      "ref")
	      checkNotEmpty "$CUSTOM_MESSAGE"
        MSG=$(uatMessage refactor "$US" "$UAT" "👩‍💻 $CUSTOM_MESSAGE")
        ;;

      "c" | "covered")
        MSG=$(uatMessage test "$US" "$UAT" "🟢 added already covered test case")
        ;;

      "d" | "done")
        MSG=$(uatMessage feat "$US" "$UAT" "🟢 done")
        ;;

      *)
        usage
	;;
    esac

    commit "$MSG" "$COMMIT_OPTS"
    ;;

  "us")
    US="$2"
    checkNotEmpty "$US"

    commit "feat(US$US): 🟢 done"
    ;;

  *)
    usage
    ;;

esac
