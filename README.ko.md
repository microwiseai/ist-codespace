<p align="center"><a href="./README.md">English</a> | <b>한국어</b></p>

# IST Workshop Codespace

**IST (Integrated Session Tools)** 를 바로 체험할 수 있는 GitHub Codespace입니다.
코드를 직접 작성할 필요는 없습니다. AI *매니저* 세션을 시작하고 프롬프트 하나를 붙여 넣으면,
매니저가 작업을 여러 AI *워커* 세션에 나누어 실제 소프트웨어를 만드는 과정을 지켜볼 수 있습니다.
필요한 도구(`isesh` 툴체인, IST UI, Claude Code, OpenAI Codex, tmux)는 모두 미리 설치되어 있습니다.

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/microwiseai/ist-codespace?quickstart=1)

## IST UI 열기

Codespace가 시작되면 **IST UI** 서버가 백그라운드에서 자동으로 실행됩니다
(포워딩 포트 **7788**, 레이블 *IST UI*). Codespace는 IST UI를 새 브라우저 탭으로 열려고 시도하지만,
브라우저가 이 팝업을 차단하는 경우가 많습니다. **IST UI 탭이 열리지 않았다면 직접 여세요:**

- 터미널에서 `ist-ui`를 실행합니다. URL이 출력되며, 서버가 실행 중이 아니면 서버도 함께 시작합니다.
  출력된 `https://…-7788…` 링크를 클릭하거나,
- **Ports** 패널 → `7788` → 지구본 아이콘(*Open in Browser*)을 클릭합니다.

```bash
ist-ui         # starts it if needed and prints the URL
ist-ui url     # just prints https://<your-codespace>-7788.<forwarding-domain>/
```

탭을 잃어버렸을 때도 같은 방법을 사용하면 됩니다. IST UI는 메인 진입점이며 두 개의 탭으로
구성됩니다:

- **Setup** — 로그인과 백그라운드 서비스: **IST account (detector-agent)**,
  **Claude Code**, **Codex CLI**, 그리고 **detector-agent** 백그라운드 에이전트. Claude Code / Codex는
  각 카드에서 바로 로그인할 수 있습니다. Claude Code나 Codex의 설치 또는 로그인이 아직 필요한 동안에는
  UI가 이 탭(탭 배지 **!**)으로 열립니다.
- **Managers** — **＋ New manager** (폴더를 선택하거나 **Use another folder** 선택; 매니저가 아직 없으면
  큰 **▶ Start a manager in this folder** 버튼 하나가 표시됨). 그 아래에는 매니저마다 한 줄씩
  **▶ Start** / **■ Stop**, **Copy attach command** (터미널에 붙여 넣으면 매니저와 대화할 수 있음),
  워커 수가 표시됩니다. 로그인이 완료되면 UI가 이 탭으로 열립니다.

**문제 해결**

- **시작 시 IST UI 탭이 열리지 않음** — 정상입니다. 브라우저가 팝업을 차단했을 뿐, 서버는 이미
  실행 중입니다. `ist-ui` 또는 **Ports** → `7788` → 지구본 아이콘으로 여세요(위 참고). 주소 표시줄에
  "팝업 차단됨" 아이콘이 보이면 `*.github.dev`에 대해 팝업을 허용할 수 있습니다.
- **페이지에서 토큰을 요구함** — `localhost`/`127.0.0.1` 주소로 접속한 경우입니다.
  `ist-ui url`을 실행해 출력되는 `https://…-7788…` 주소로 대신 접속하세요.
- **포트 7788에 아무것도 없음** — `ist-ui status`로 확인하세요. `ist-ui stop` 후 `ist-ui`로
  재시작합니다. 로그: `~/.cache/ist-codespace/start-ui.log` (Codespace 시작) 및 `~/.ist/ui/serve.log` (UI 서버).
- **포트 7788을 절대 Public으로 설정하지 마세요.** 공개 범위는 *Private*(기본값)으로 유지하세요.
  포워딩 주소를 통해 접속하면 UI는 토큰을 요구하지 않으며 — GitHub 로그인이 이를 보호합니다 —
  접근할 수 있는 사람은 누구나 계정 로그인/로그아웃과 에이전트 시작/중지를 할 수 있습니다.

## 워크숍

| # | 워크숍 | 소요 시간 |
|---|----------|------|
| 00 | [quicktool — 30분 만에 CLI 만들기](workshops/00-quicktool/README.md) | 약 30분 |
| 01 | [IST로 테트리스 만들기](workshops/01-tetris/README.md) | 약 60분 |
| 02 | [IST로 변환 키트 만들기 (HWP / HWPX → Markdown)](workshops/02-converter-kit/README.md) | 약 90분 |

IST가 처음이라면 **00**부터 시작하세요. 개요: [workshops/README.md](workshops/README.md).

## 사전 준비

- GitHub 계정
- AI CLI 인증 수단 (둘 다 미리 설치되어 있음):
  - **Claude Code** — Claude Pro/Max 구독 (`claude login`) **또는** [Anthropic API 키](https://console.anthropic.com/)
  - **OpenAI Codex** — ChatGPT 플랜 (`codex login --device-auth`) **또는** [OpenAI API 키](https://platform.openai.com/api-keys)

## 로그인

Codespace에는 어떤 자격 증명도 미리 주입되지 않으므로 직접 로그인해야 합니다. 가장 쉬운 방법은
IST UI의 **Setup** 탭(**Claude Code** / **Codex CLI** 카드)을 이용하는 것입니다. 또는 터미널에서:

```bash
# Claude Code
claude login                                  # Claude Pro/Max subscription
export ANTHROPIC_API_KEY=sk-ant-...           # ...or an API key

# OpenAI Codex
codex login --device-auth                     # ChatGPT plan (device code)
printenv OPENAI_API_KEY | codex login --with-api-key   # ...or an API key
```

**선택 사항 — 자동 승인 및 웹 대시보드:** **IST account (detector-agent)** 카드에서
로그인(**Sign in with Google**)하거나, `detector-agent login`을 한 번 실행하세요(OAuth 콜백은
포워딩 포트 9876을 사용). 그러면 `smon`이 일상적인 에이전트 프롬프트를 자동 승인할 수 있고,
https://ism.microwiseai.com 에서 세션을 실시간으로 볼 수 있습니다.

## 동작 방식

매니저 프롬프트를 AI 세션에 붙여 넣으면 매니저는:
1. 제품 스펙을 읽고
2. 각 단계별로 워커 세션을 생성하며
3. 워커들이 코드를 작성하고 (스펙이 허용하는 경우 병렬로)
4. 매니저가 리뷰와 테스트를 수행합니다. 여러분은 모든 과정을 실시간으로 지켜보면 됩니다.

코드 작성은 필요 없습니다. 오케스트레이션만 하면 됩니다.

## 프리빌드로 속도 높이기

devcontainer는 전체 툴체인을 이미지에 미리 포함하므로, **Codespaces Prebuild**를 설정하면
"Open in Codespaces"가 매번 빨라집니다. 저장소/조직 소유자가 한 번만 설정하면 됩니다:

1. GitHub의 저장소 → **Settings → Codespaces → Prebuilds → Set up prebuild**로 이동합니다
   (조직 전체: **Org Settings → Codespaces → Prebuilds**).
2. 이 저장소와 브랜치(예: `main`)를 선택합니다.
3. 사용자와 가까운 리전을 선택한 뒤 저장합니다.

GitHub가 이미지를 미리 빌드하고, `.devcontainer/**`를 변경하는 push가 있을 때마다 갱신합니다.
첫 프리빌드 이후에는 Codespace를 열 때 캐시를 사용합니다.
(IST UI는 컨테이너 시작 시 실행되는 `postStartCommand`로 시작되며 프리빌드 중에는 실행되지 않으므로,
프리빌드에는 영향이 없습니다.)

## 프로젝트 구조

```
workshops/
  README.md            # workshop index
  00-quicktool/        # README + guide/ (steps) + project/ (spec, manager prompt, starter config)
  01-tetris/           # README + project/
  02-converter-kit/    # README + project/
.devcontainer/
  Dockerfile           # prebakes isesh / snapshot / claude-code / codex / ist-ui (via glpkg)
  devcontainer.json    # ports 7788 (IST UI) + 9876 (detector-agent login), start/attach hooks
  start-ui.sh          # postStartCommand: launches the IST UI in the background
  welcome.sh           # postAttachCommand: welcome banner
```
