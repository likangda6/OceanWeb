<%--
  Created by IntelliJ IDEA.
  User: 30202
  Date: 2025/8/8
  Time: 19:43
  To change this template use File | Settings and File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
  <title>海洋生物猜猜乐 | 科普游戏</title>
  <!-- Vue 2 + Element UI CDN -->
  <link rel="stylesheet" href="https://unpkg.com/element-ui@2.15.14/lib/theme-chalk/index.css">
  <style>
    [v-cloak] { display: none; }
    * { box-sizing: border-box; }

    body {
      background-image: url('/images/game/newBoard.jpg');
      background-size: cover;
      background-position: center;
      background-attachment: fixed;
      margin: 0;
      padding: 0;
      font-family: 'Microsoft YaHei', 'PingFang SC', 'Helvetica Neue', sans-serif;
      color: white;
      overflow: hidden;
      min-height: 100vh;
      min-height: 100dvh;
      -webkit-tap-highlight-color: transparent;
      -webkit-font-smoothing: antialiased;
    }

    .body {
      margin: 0;
      padding: 0;
      width: 100%;
      min-height: 100vh;
      min-height: 100dvh;
      display: flex;
      flex-direction: column;
    }

    /* ============ 游戏容器 ============ */
    .game-container {
      max-height: 80vh;
      max-height: 80dvh;
      max-width: 900px;
      margin: 20px auto 30px;
      background-color: rgba(0, 0, 0, 0.7);
      padding: 20px;
      padding-top: 10px;
      border-radius: 15px;
      box-shadow: 0 0 20px rgba(0, 255, 255, 0.3);
      position: relative;
      overflow-y: auto;
      -webkit-overflow-scrolling: touch;
      flex-shrink: 1;
    }

    .game-title {
      text-align: center;
      color: #00ffff;
      margin-bottom: 20px;
      text-shadow: 0 0 10px rgba(0, 255, 255, 0.5);
      font-size: 2.5rem;
      line-height: 1.2;
    }

    /* ============ 规则页面 ============ */
    .rules-container { text-align: center; }

    .rules-content {
      background-color: rgba(0, 50, 80, 0.5);
      padding: 20px;
      border-radius: 10px;
      margin-bottom: 20px;
      border: 1px solid #00aaff;
      text-align: left;
    }

    .rules-list { list-style-type: none; padding: 0; }

    .rules-list li {
      margin-bottom: 12px;
      padding-left: 22px;
      position: relative;
      font-size: 1.1rem;
      line-height: 1.6;
    }

    .rules-list li:before {
      content: "•";
      color: #00ffaa;
      font-size: 1.5rem;
      position: absolute;
      left: 0;
      top: -3px;
    }

    .start-btn {
      padding: 15px 40px;
      font-size: 1.2rem;
      margin-top: 20px;
      min-height: 50px;
    }

    /* ============ 游戏区域 ============ */
    .clue-section {
      margin: auto;
      width: 90%;
      background-color: rgba(0, 50, 80, 0.5);
      padding: 16px;
      border-radius: 10px;
      margin-bottom: 16px;
      border: 1px solid #00aaff;
    }

    .clue-section h3 { margin-top: 0; font-size: 1rem; color: #00ffff; }

    .clue-item {
      margin-bottom: 12px;
      font-size: 1rem;
      line-height: 1.5;
      word-break: break-word;
    }

    .clue-category {
      font-weight: bold;
      color: #00ffaa;
      margin-right: 8px;
      white-space: nowrap;
    }

    .guess-section {
      width: 100%;
      display: flex;
      flex-direction: column;
      align-items: center;
    }

    .guess-input .el-textarea__inner,
    .guess-input .el-input__inner {
      width: 100%;
      max-width: 500px;
      padding: 12px 16px;
      border-radius: 8px;
      font-size: 16px;
      background-color: rgba(255, 255, 255, 0.9);
      border: 2px solid transparent;
      transition: border-color 0.3s;
      -webkit-appearance: none;
      appearance: none;
    }
    .guess-input .el-input__inner:focus {
      border-color: #00ffff;
      box-shadow: 0 0 8px rgba(0, 255, 255, 0.4);
    }

    .buttons {
      display: flex;
      gap: 12px;
      margin-bottom: 16px;
      justify-content: center;
      flex-wrap: wrap;
    }

    .game-btn {
      min-width: 110px;
      min-height: 46px;
      white-space: nowrap;
    }

    .score-board {
      background-color: rgba(0, 0, 0, 0.7);
      padding: 10px 20px;
      border-radius: 10px;
      margin: 16px auto;
      width: fit-content;
      border: 1px solid #00ffff;
      text-align: center;
    }

    .score-item {
      margin: 4px 0;
      font-size: 1rem;
      white-space: nowrap;
    }

    .point-value { color: #ffcc00; font-weight: bold; }

    .result-section {
      margin-top: 16px;
      text-align: center;
      min-height: 40px;
      font-size: 16px;
    }

    .result-correct { color: #4CAF50; font-weight: bold; }
    .result-incorrect { color: #f44336; }
    .result-skipped { color: #ff9800; }

    .marine-image {
      max-width: 280px;
      max-height: 180px;
      border-radius: 10px;
      margin: 16px auto;
      display: block;
      border: 2px solid #00ffff;
      object-fit: cover;
    }

    /* ============ 弹窗内容样式 ============ */
    .animation-container {
      position: absolute;
      top: -80px;
      left: -160px;
      z-index: 999;
      width: 300px;
      height: 300px;
      background-image: url("/images/game/9991.png");
      background-repeat: no-repeat;
      background-size: 20000px 300px;
      animation: play-sprite 6s steps(50) infinite;
      display: none;
      animation-play-state: paused;
      pointer-events: none;
    }

    @keyframes play-sprite {
      0% { background-position: 0 0; }
      100% { background-position: -20000px 0; }
    }

    .game-modal .el-dialog {
      background-color: rgba(0, 50, 80, 0.95);
      border: 2px solid #00aaff;
      border-radius: 15px;
      box-shadow: 0 0 25px rgba(0, 255, 255, 0.5);
      max-width: 500px;
      width: 85%;
    }
    .game-modal .el-dialog__header { display: none; }
    .game-modal .el-dialog__body { padding: 22px; color: #fff; }

    .modal-correct .el-dialog { border-color: #4CAF50 !important; }
    .modal-incorrect .el-dialog { border-color: #f44336 !important; }
    .modal-skipped .el-dialog { border-color: #ff9800 !important; }

    .modal-title {
      font-size: 1.5rem;
      margin-bottom: 16px;
      color: #00ffff;
      text-align: center;
      line-height: 1.3;
    }

    .modal-message {
      font-size: 1rem;
      line-height: 1.6;
      text-align: left;
      word-break: break-word;
    }

    .modal-image {
      max-width: 220px;
      max-height: 150px;
      border-radius: 8px;
      margin: 12px auto;
      border: 2px solid #00ffff;
      box-shadow: 0 0 15px rgba(0, 255, 255, 0.3);
      display: block;
      object-fit: cover;
    }

    .modal-buttons { text-align: center; margin-top: 16px; }

    .creature-info {
      background-color: rgba(0, 30, 50, 0.5);
      border-radius: 8px;
      padding: 14px;
      margin-top: 12px;
    }

    .info-row {
      margin-bottom: 8px;
      line-height: 1.5;
      padding: 4px 0;
      border-bottom: 1px dashed rgba(0, 255, 255, 0.2);
      word-break: break-word;
    }
    .info-row:last-child { border-bottom: none; margin-bottom: 0; }

    .info-label {
      color: #00ffaa;
      font-weight: bold;
      display: inline-block;
      min-width: 70px;
    }

    .correct-answer {
      text-align: center;
      font-size: 1.1em;
      margin-bottom: 12px;
      padding: 10px;
      background-color: rgba(0, 50, 80, 0.3);
      border-radius: 5px;
    }

    .creature-name { color: #00ffff; font-weight: bold; font-size: 1.2em; }

    @keyframes shake {
      0%, 100% { transform: translateX(0); }
      20%, 60% { transform: translateX(-8px); }
      40%, 80% { transform: translateX(8px); }
    }
    .shake { animation: shake 0.5s; }

    /* ============ 设置按钮 ============ */
    .settings-btn {
      position: absolute;
      top: 15px;
      right: 15px;
      background-color: rgba(0, 150, 200, 0.7);
      border: none;
      border-radius: 50%;
      width: 38px;
      height: 38px;
      cursor: pointer;
      display: flex;
      justify-content: center;
      align-items: center;
      transition: all 0.3s;
      z-index: 10;
      -webkit-tap-highlight-color: transparent;
      touch-action: manipulation;
    }
    .settings-btn:hover {
      background-color: rgba(0, 180, 230, 0.9);
      transform: rotate(30deg);
    }
    .settings-btn:active { transform: scale(0.9) rotate(30deg); }
    .settings-btn img { width: 22px; height: 22px; filter: brightness(0) invert(1); pointer-events: none; }

    .settings-panel {
      position: absolute;
      top: 60px;
      right: 15px;
      background-color: rgba(0, 50, 80, 0.95);
      border: 1px solid #00aaff;
      border-radius: 10px;
      padding: 15px;
      width: 240px;
      z-index: 10;
      box-shadow: 0 0 15px rgba(0, 255, 255, 0.3);
    }

    .settings-panel h3 {
      margin-top: 0;
      color: #00ffff;
      text-align: center;
      border-bottom: 1px solid rgba(0, 255, 255, 0.3);
      padding-bottom: 10px;
      font-size: 1.1rem;
    }

    .setting-item { margin-bottom: 14px; }
    .setting-item > label {
      display: block;
      margin-bottom: 5px;
      color: #00ffaa;
      font-size: 0.95rem;
    }

    .volume-control { display: flex; align-items: center; gap: 10px; }
    .volume-value { color: #00ffaa; font-size: 0.9rem; min-width: 40px; }

    /* ============ 平板端适配 (768px及以下) ============ */
    @media (max-width: 768px) {
      .game-container {
        max-height: 75vh;
        max-height: 75dvh;
        max-width: 95%;
        margin: 15px auto 20px;
        padding: 15px 12px;
        border-radius: 12px;
      }
      .game-title { font-size: 1.8rem; margin-bottom: 14px; padding-right: 35px; }
      .rules-content { padding: 14px; }
      .rules-list li { font-size: 0.95rem; margin-bottom: 10px; padding-left: 18px; }
      .start-btn { padding: 14px 35px; font-size: 1.1rem; min-height: 48px; width: 80%; max-width: 300px; }
      .clue-section { width: 95%; padding: 12px; }
      .clue-item { font-size: 0.9rem; margin-bottom: 10px; }
      .guess-input .el-input__inner { width: 90%; padding: 11px 14px; font-size: 15px; border-radius: 6px; }
      .buttons { gap: 8px; }
      .game-btn { padding: 10px 16px; font-size: 14px; min-width: 90px; min-height: 42px; border-radius: 6px; }
      .score-board { padding: 8px 14px; margin: 12px auto; }
      .score-item { font-size: 0.9rem; }
      .marine-image { max-width: 200px; max-height: 130px; }
      .game-modal .el-dialog { width: 92%; max-width: 450px; }
      .modal-title { font-size: 1.3rem; }
      .modal-message { font-size: 0.9rem; }
      .modal-image { max-width: 170px; max-height: 120px; }
      .animation-container { width: 200px; height: 200px; top: -50px; left: -100px; background-size: 13400px 200px; }
      @keyframes play-sprite { 0% { background-position: 0 0; } 100% { background-position: -13400px 0; } }
      .settings-btn { top: 10px; right: 8px; width: 34px; height: 34px; }
      .settings-btn img { width: 18px; height: 18px; }
      .settings-panel { top: 50px; right: 5px; width: 210px; padding: 12px; }
      .settings-panel h3 { font-size: 1rem; }
      .info-label { min-width: 55px; display: inline; }
      .correct-answer { font-size: 1em; }
      .creature-name { font-size: 1.1em; }
    }

    /* ============ 小屏手机适配 (480px及以下) ============ */
    @media (max-width: 480px) {
      .game-container {
        max-height: 72vh;
        max-height: 72dvh;
        max-width: 98%;
        margin: 8px auto 12px;
        padding: 10px 8px;
        border-radius: 10px;
      }
      .game-title { font-size: 1.4rem; margin-bottom: 10px; padding-right: 30px; }
      .rules-content { padding: 10px; }
      .rules-list li { font-size: 0.85rem; margin-bottom: 8px; padding-left: 16px; line-height: 1.4; }
      .rules-list li:before { font-size: 1.2rem; top: -2px; }
      .start-btn { padding: 12px 25px; font-size: 1rem; min-height: 44px; width: 90%; max-width: 260px; border-radius: 6px; }
      .clue-section { width: 98%; padding: 10px; }
      .clue-section h3 { font-size: 0.9rem; }
      .clue-item { font-size: 0.82rem; margin-bottom: 8px; }
      .guess-input .el-input__inner { width: 95%; padding: 10px 12px; font-size: 14px; border-radius: 6px; }
      .buttons { gap: 6px; }
      .game-btn { padding: 10px 12px; font-size: 13px; min-width: 70px; min-height: 38px; border-radius: 6px; }
      .score-board { padding: 6px 10px; margin: 10px auto; border-radius: 8px; }
      .score-item { font-size: 0.8rem; }
      .marine-image { max-width: 150px; max-height: 100px; border-radius: 8px; }
      .game-modal .el-dialog { width: 95%; padding: 14px 10px; }
      .modal-title { font-size: 1.15rem; margin-bottom: 10px; }
      .modal-message { font-size: 0.82rem; line-height: 1.5; }
      .modal-image { max-width: 130px; max-height: 90px; }
      .animation-container { width: 140px; height: 140px; top: -35px; left: -60px; background-size: 9400px 140px; }
      @keyframes play-sprite { 0% { background-position: 0 0; } 100% { background-position: -9400px 0; } }
      .settings-btn { top: 8px; right: 5px; width: 30px; height: 30px; }
      .settings-btn img { width: 16px; height: 16px; }
      .settings-panel { top: 42px; right: 2px; width: 185px; padding: 10px; border-radius: 8px; }
      .settings-panel h3 { font-size: 0.9rem; padding-bottom: 8px; }
      .setting-item { margin-bottom: 10px; }
      .setting-item > label { font-size: 0.82rem; }
      .creature-info { padding: 10px; }
      .info-row { font-size: 0.82rem; margin-bottom: 6px; }
      .info-label { min-width: 45px; font-size: 0.8rem; }
      .correct-answer { font-size: 0.9em; padding: 8px; }
      .creature-name { font-size: 1em; }
      .result-section { font-size: 14px; min-height: 30px; }
    }

    /* ============ 超小屏手机适配 (360px及以下) ============ */
    @media (max-width: 360px) {
      .game-container { max-height: 70vh; max-height: 70dvh; padding: 8px 5px; }
      .game-title { font-size: 1.2rem; }
      .game-btn { padding: 8px 10px; font-size: 12px; min-width: 60px; min-height: 34px; }
      .game-modal .el-dialog { width: 98%; padding: 10px 7px; }
      .modal-title { font-size: 1rem; }
      .animation-container { width: 110px; height: 110px; top: -25px; left: -40px; background-size: 7400px 110px; }
      @keyframes play-sprite { 0% { background-position: 0 0; } 100% { background-position: -7400px 0; } }
      .settings-panel { width: 165px; right: 0; }
    }

    /* ============ 横屏手机适配 ============ */
    @media (max-width: 900px) and (orientation: landscape) {
      .game-container { max-height: 65vh; max-height: 65dvh; max-width: 90%; margin: 8px auto; }
      .game-title { font-size: 1.4rem; margin-bottom: 8px; }
      .clue-section { width: 95%; padding: 8px 12px; }
      .clue-item { font-size: 0.8rem; margin-bottom: 6px; }
      .guess-input .el-input__inner { width: 80%; padding: 8px 12px; font-size: 14px; }
      .buttons { gap: 6px; }
      .game-btn { padding: 8px 14px; font-size: 13px; min-height: 36px; }
      .game-modal .el-dialog { max-height: 70vh; max-height: 70dvh; padding: 12px; }
    }
  </style>
</head>

<body>
<div class="body">
  <%@ include file="navbar.jsp" %>

  <!-- 游戏内容区域 -->
  <div id="appGame" class="game-container" v-cloak>
    <!-- 设置按钮 -->
    <button class="settings-btn" title="设置" aria-label="打开设置" @click="settingsOpen = !settingsOpen">
      <img src="/images/game/setting.png" alt="设置">
    </button>

    <!-- 设置面板 -->
    <div class="settings-panel" v-show="settingsOpen">
      <h3>游戏设置</h3>
      <div class="setting-item">
        <label>背景音乐</label>
        <el-switch v-model="musicEnabled" active-color="#13ce66" inactive-color="#ff4949"
                   @change="toggleMusic"></el-switch>
      </div>
      <div class="setting-item">
        <label>音量大小</label>
        <div class="volume-control">
          <el-slider v-model="volumeLevel" :min="0" :max="100" :show-tooltip="false" style="flex-grow:1;"
                     @input="adjustVolume"></el-slider>
          <span class="volume-value">{{ volumeLevel }}%</span>
        </div>
      </div>
      <div class="setting-item">
        <el-button size="small" style="width: 100%;" @click="settingsOpen = false">关闭设置</el-button>
      </div>
    </div>

    <h1 class="game-title">海洋生物猜猜乐</h1>

    <!-- 规则页面 -->
    <div class="rules-container" v-show="!gameStarted">
      <div class="rules-content">
        <h2 style="text-align: center; color: #00ffaa; margin-bottom: 16px;">游戏规则</h2>
        <ul class="rules-list">
          <li>系统会<strong>依次给出</strong>海洋生物的线索，包括分类、栖息地、特征、习性和趣味事实。</li>
          <li>初始时只显示<strong>第一条线索</strong>，你可以点击"更多线索"按钮获取更多信息。</li>
          <li>每条额外线索会<strong>减少该题得分</strong>，越早猜出得分越高！</li>
          <li>每题基础分10分，每获取一条额外线索扣2分，最低可得2分。</li>
          <li>猜不出来可以点击"跳过"进入下一题，但不得分。</li>
          <li>每轮游戏共有<strong>5道题目</strong>，答完所有题目后游戏结束。</li>
        </ul>
      </div>
      <el-button type="success" class="start-btn" @click="startGame">开始游戏</el-button>
    </div>

    <!-- 游戏区域 -->
    <div v-show="gameStarted">
      <div class="score-board">
        <div class="score-item">得分: <span>{{ score }}</span></div>
        <div class="score-item">回合: <span>{{ round }}/{{ maxRounds }}</span></div>
        <div class="score-item">本题分值: <span class="point-value">{{ currentPoints }}</span>分</div>
      </div>

      <div class="clue-section">
        <h3>线索提示: ({{ currentClueCount }}/5)</h3>
        <div class="clue-item" v-if="currentClueCount >= 1">
          <span class="clue-category">分类:</span>
          <span>{{ currentCreature.classification }}</span>
        </div>
        <div class="clue-item" v-if="currentClueCount >= 2">
          <span class="clue-category">栖息地:</span>
          <span>{{ currentCreature.habitat }}</span>
        </div>
        <div class="clue-item" v-if="currentClueCount >= 3">
          <span class="clue-category">特征:</span>
          <span>{{ currentCreature.characteristics }}</span>
        </div>
        <div class="clue-item" v-if="currentClueCount >= 4">
          <span class="clue-category">习性:</span>
          <span>{{ currentCreature.behavior }}</span>
        </div>
        <div class="clue-item" v-if="currentClueCount >= 5">
          <span class="clue-category">趣味事实:</span>
          <span>{{ currentCreature.funfact }}</span>
        </div>
      </div>

      <img v-if="showImage && currentCreature.image" :src="currentCreature.image"
           class="marine-image" alt="海洋生物" @error="onImageError">

      <div class="guess-section">
        <el-input v-model="guessInput" class="guess-input" placeholder="请输入你猜的海洋生物名称..."
                  autocomplete="off" @keydown.enter.native="checkGuess"
                  :class="{ shake: shakeInput }"></el-input>

        <div class="buttons">
          <el-button type="primary" class="game-btn" v-if="currentClueCount < 5 && !answered"
                     @click="showMoreClues">更多线索 (-2分)</el-button>
          <el-button type="warning" class="game-btn" v-if="!answered" @click="skipQuestion">跳过</el-button>
          <el-button type="success" class="game-btn" v-if="!answered" @click="checkGuess">提交答案</el-button>
          <el-button type="warning" class="game-btn" v-if="answered" @click="nextRound">下一题</el-button>
        </div>

        <div class="result-section" :class="resultClass" v-if="resultText">{{ resultText }}</div>
      </div>
    </div>

    <!-- 结果弹窗 -->
    <el-dialog :visible.sync="modalVisible" :modal="true" :close-on-click-modal="false"
               :close-on-press-escape="false" :show-close="false" custom-class="game-modal"
               :class="modalClass" width="85%" append-to-body>
      <div class="animation-container" ref="animationContainer"></div>
      <h2 class="modal-title">{{ modalTitle }}</h2>
      <img v-if="modalImage" :src="modalImage" class="modal-image" alt="海洋生物图片">
      <div class="modal-message" v-html="modalMessage"></div>
      <div class="modal-buttons">
        <el-button v-if="modalType === 'gameover'" type="success" @click="restartGame">再玩一次</el-button>
        <el-button type="primary" @click="closeModal">关闭</el-button>
      </div>
    </el-dialog>
  </div>
</div>

<!-- 背景音乐 -->
<audio id="bgMusic" loop preload="none">
  <source src="/images/game/RiverR.mp3" type="audio/mpeg">
</audio>
<!-- 音效 -->
<audio id="correctSound" preload="auto">
  <source src="/images/game/success.wav" type="audio/mpeg">
</audio>
<audio id="wrongSound" preload="auto">
  <source src="/images/game/fail.wav" type="audio/mpeg">
</audio>

<script src="https://unpkg.com/vue@2.7.16/dist/vue.js"></script>
<script src="https://unpkg.com/element-ui@2.15.14/lib/index.js"></script>
<script>
  // 海洋生物数据库
  const marineCreatures = [{
    name: "海豚",
    classification: "哺乳纲-鲸目-海豚科",
    habitat: "全球各大洋，部分淡水区域",
    characteristics: "流线型身体，背鳍明显，聪明活泼",
    behavior: "群居，高度社会化，使用回声定位",
    funfact: "它们会给自己取名字，用独特的哨声标识",
    image: "/images/game/animals/dolphin.jpg"
  }, {
    name: "海龟",
    classification: "爬行纲-龟鳖目-海龟科",
    habitat: "全球热带和亚热带海域",
    characteristics: "流线型壳，鳍状四肢，无法缩入壳内",
    behavior: "迁徙性强，返回出生地产卵",
    funfact: "可以感知地球磁场来导航",
    image: "/images/game/animals/seaTurtle.jpg"
  }, {
    name: "小丑鱼",
    classification: "硬骨鱼纲-鲈形目-雀鲷科",
    habitat: "印度洋和太平洋的珊瑚礁",
    characteristics: "橙白相间的条纹，与海葵共生",
    behavior: "社会性鱼类，有严格的等级制度",
    funfact: "所有小丑鱼出生时都是雄性，有些会转变为雌性",
    image: "/images/game/animals/clownfish.jpg"
  }, {
    name: "海星",
    classification: "棘皮动物门-海星纲",
    habitat: "全球各海域的潮间带和深海",
    characteristics: "五角星形状，多颜色，能再生肢体",
    behavior: "缓慢移动，以贝类为食",
    funfact: "胃可以翻出体外消化食物",
    image: "/images/game/animals/starfish.jpg"
  }, {
    name: "章鱼",
    classification: "软体动物门-头足纲-章鱼科",
    habitat: "全球各海域的珊瑚礁和海底",
    characteristics: "八条腕足，无骨骼，能变色伪装",
    behavior: "独居，聪明，会使用工具",
    funfact: "有三个心脏和蓝色血液",
    image: "/images/game/animals/octopus.jpg"
  }, {
    name: "海马",
    classification: "硬骨鱼纲-海龙目-海龙科",
    habitat: "热带和温带浅海区域",
    characteristics: "头部像马，身体有环状骨板，尾巴可卷曲",
    behavior: "雄性负责孵化幼崽，游泳能力差",
    funfact: "这是唯一一种雄性怀孕的动物",
    image: "/images/game/animals/seaHorse.jpg"
  }, {
    name: "水母",
    classification: "刺胞动物门-钵水母纲",
    habitat: "全球各海域，从表层到深海",
    characteristics: "伞状身体，透明或彩色，有触手",
    behavior: "随水流漂浮，用触手捕食",
    funfact: "身体95%是水，没有大脑和心脏",
    image: "/images/game/animals/acaleph.jpg"
  }, {
    name: "鲨鱼",
    classification: "软骨鱼纲-鲨目",
    habitat: "全球各大洋",
    characteristics: "流线型身体，多排牙齿，皮肤粗糙",
    behavior: "顶级掠食者，嗅觉极其灵敏",
    funfact: "有些种类可以活到400岁",
    image: "/images/game/animals/shark.jpg"
  }, {
    name: "海豹",
    classification: "哺乳纲-食肉目-海豹科",
    habitat: "北极、南极和温带海域",
    characteristics: "流线型身体，四肢演化成鳍状",
    behavior: "群居，擅长游泳和潜水",
    funfact: "可以在水下屏住呼吸长达2小时",
    image: "/images/game/animals/seal.jpg"
  }, {
    name: "珊瑚",
    classification: "刺胞动物门-珊瑚纲",
    habitat: "热带和亚热带浅海",
    characteristics: "由无数珊瑚虫组成，形态多样，色彩丰富",
    behavior: "与虫黄藻共生，夜间捕食浮游生物",
    funfact: "珊瑚礁被称为海洋中的热带雨林",
    image: "/images/game/animals/coral.jpg"
  }];

  new Vue({
    el: '#appGame',
    data: {
      // 游戏状态
      gameStarted: false,
      score: 0,
      round: 1,
      maxRounds: 5,
      currentClueCount: 1,
      currentPoints: 10,
      currentCreature: { classification: '', habitat: '', characteristics: '', behavior: '', funfact: '', image: '' },
      usedCreatures: [],
      guessInput: '',
      answered: false,
      showImage: false,
      shakeInput: false,
      resultText: '',
      resultClass: '',
      // 设置
      settingsOpen: false,
      musicEnabled: true,
      volumeLevel: 50,
      ttsEnabled: true,
      isSpeaking: false,
      // 弹窗
      modalVisible: false,
      modalTitle: '',
      modalMessage: '',
      modalImage: '',
      modalType: '',
      modalClass: ''
    },
    computed: {
      bgMusic: function () { return document.getElementById('bgMusic'); },
      correctSound: function () { return document.getElementById('correctSound'); },
      wrongSound: function () { return document.getElementById('wrongSound'); }
    },
    mounted: function () {
      this.initSettings();
      if (window.speechSynthesis) {
        var self = this;
        window.speechSynthesis.onvoiceschanged = function () { console.log('语音列表已加载'); };
      } else {
        console.warn('当前浏览器不支持语音合成API');
        this.ttsEnabled = false;
      }
    },
    beforeDestroy: function () {
      if (window.speechSynthesis) window.speechSynthesis.cancel();
    },
    methods: {
      // ===== 设置相关 =====
      initSettings: function () {
        this.musicEnabled = localStorage.getItem('musicEnabled') !== 'false';
        this.volumeLevel = parseInt(localStorage.getItem('volumeLevel')) || 50;
        this.bgMusic.volume = this.volumeLevel / 100;
        if (this.musicEnabled) {
          this.bgMusic.play().catch(function (e) { console.log('自动播放被阻止:', e); });
        } else {
          this.bgMusic.pause();
        }
      },
      toggleMusic: function (val) {
        localStorage.setItem('musicEnabled', val);
        if (val) {
          this.bgMusic.play().catch(function (e) { console.log('播放被阻止:', e); });
        } else {
          this.bgMusic.pause();
        }
      },
      adjustVolume: function () {
        var vol = this.volumeLevel / 100;
        this.bgMusic.volume = vol;
        localStorage.setItem('volumeLevel', this.volumeLevel);
      },

      // ===== 童声朗读 =====
      speakWithChildVoice: function (text) {
        if (!this.ttsEnabled || this.isSpeaking || !window.speechSynthesis) return;
        var self = this;
        try {
          this.isSpeaking = true;
          window.speechSynthesis.cancel();
          var animationContainer = this.$refs.animationContainer;
          var cleanText = text.replace(/<[^>]*>?/gm, '');
          if (!cleanText) { this.isSpeaking = false; return; }

          var utterance = new SpeechSynthesisUtterance(cleanText);
          utterance.lang = 'zh-CN';
          utterance.rate = 1.1;
          utterance.pitch = 1.8;
          utterance.volume = 0.9;

          var voices = window.speechSynthesis.getVoices();
          var childVoices = voices.filter(function (v) {
            return v.lang.includes('zh') &&
              (v.name.includes('Mei-Jia') || v.name.includes('TingTing') ||
                v.name.includes('Child') || v.name.includes('Xiaoxiao'));
          });
          if (childVoices.length > 0) {
            utterance.voice = childVoices[0];
          } else {
            var chineseVoices = voices.filter(function (v) { return v.lang.includes('zh'); });
            if (chineseVoices.length) {
              utterance.voice = chineseVoices.reduce(function (a, b) {
                return (a.name.includes('Female') ? 1 : 0) > (b.name.includes('Female') ? 1 : 0) ? a : b;
              });
            }
          }

          utterance.onstart = function () {
            if (animationContainer) {
              animationContainer.style.display = 'block';
              animationContainer.style.animationPlayState = 'running';
            }
          };
          utterance.onend = utterance.onerror = function () {
            if (animationContainer) {
              animationContainer.style.animationPlayState = 'paused';
              animationContainer.style.display = 'none';
            }
            self.isSpeaking = false;
          };
          window.speechSynthesis.speak(utterance);
        } catch (e) {
          console.error('语音合成错误:', e);
          this.isSpeaking = false;
        }
      },

      // ===== 游戏逻辑 =====
      startGame: function () {
        this.gameStarted = true;
        if (this.musicEnabled) {
          this.bgMusic.play().catch(function (e) { console.log('播放被阻止:', e); });
        }
        this.score = 0;
        this.round = 1;
        this.usedCreatures = [];
        this.startNewRound();
        this.$message({ message: '游戏开始！加油猜吧', type: 'success', duration: 2000 });
      },

      startNewRound: function () {
        this.currentClueCount = 1;
        this.currentPoints = 10;
        this.answered = false;
        this.showImage = false;
        this.guessInput = '';
        this.resultText = '';
        this.resultClass = '';

        var availableCreatures = marineCreatures.filter(function (c) {
          return !this.usedCreatures.includes(c.name);
        }, this);
        if (availableCreatures.length === 0) {
          availableCreatures = marineCreatures.slice();
          this.usedCreatures = [];
        }
        var randomIndex = Math.floor(Math.random() * availableCreatures.length);
        this.currentCreature = Object.assign({}, availableCreatures[randomIndex]);
        this.usedCreatures.push(this.currentCreature.name);
      },

      showMoreClues: function () {
        if (this.currentClueCount < 5) {
          this.currentClueCount++;
          this.currentPoints = Math.max(2, this.currentPoints - 2);
        }
      },

      getCreatureDescription: function (creature) {
        return '<div class="creature-info">' +
          '<div class="info-row"><span class="info-label">分类:</span> ' + creature.classification + '</div>' +
          '<div class="info-row"><span class="info-label">栖息地:</span> ' + creature.habitat + '</div>' +
          '<div class="info-row"><span class="info-label">特征:</span> ' + creature.characteristics + '</div>' +
          '<div class="info-row"><span class="info-label">习性:</span> ' + creature.behavior + '</div>' +
          '<div class="info-row"><span class="info-label">趣味事实:</span> ' + creature.funfact + '</div>' +
          '</div>';
      },

      playSound: function (sound, volume) {
        volume = volume || 0.7;
        if (localStorage.getItem('soundEnabled') === 'false') return;
        sound.currentTime = 0;
        sound.volume = volume;
        sound.play().catch(function (e) { console.log('音效播放失败:', e); });
      },

      onImageError: function (e) {
        e.target.style.display = 'none';
      },

      checkGuess: function () {
        var guess = this.guessInput.trim().toLowerCase();
        var correctAnswer = this.currentCreature.name.toLowerCase();

        if (guess === '') {
          this.$message({ message: '请输入你的猜测！', type: 'warning', duration: 2000 });
          return;
        }

        if (guess === correctAnswer) {
          this.playSound(this.correctSound);
          this.score += this.currentPoints;
          this.answered = true;
          this.resultText = '回答正确！获得 ' + this.currentPoints + ' 分';
          this.resultClass = 'result-correct';
          var correctMsg = '<div style="text-align: center; margin-bottom: 12px; font-size: 1.1em;">' +
            '恭喜你答对了！获得 <span style="color: #ffcc00; font-weight: bold;">' + this.currentPoints + '分</span></div>' +
            '<div class="correct-answer">正确答案是: <span class="creature-name">' + this.currentCreature.name + '</span></div>' +
            this.getCreatureDescription(this.currentCreature);
          this.showModal('回答正确！', correctMsg, 'correct', this.currentCreature.image);
        } else {
          this.playSound(this.wrongSound);
          this.shakeInput = true;
          var self = this;
          setTimeout(function () { self.shakeInput = false; }, 500);
          this.$message({ message: '回答错误，再试试看！', type: 'error', duration: 2000 });
        }
      },

      skipQuestion: function () {
        this.answered = true;
        this.resultText = '已跳过本题';
        this.resultClass = 'result-skipped';
        var skipMsg = '<div class="correct-answer">正确答案是: <span class="creature-name">' +
          this.currentCreature.name + '</span></div>' + this.getCreatureDescription(this.currentCreature);
        this.showModal('已跳过本题', skipMsg, 'skipped', this.currentCreature.image);
      },

      showModal: function (title, message, type, imageUrl) {
        this.modalTitle = title;
        this.modalMessage = message;
        this.modalImage = imageUrl || '';
        this.modalType = type;
        this.modalClass = 'modal-' + type;

        var description = '';
        if (type === 'correct') {
          description = '答对啦！这是' + this.currentCreature.name + '，' + this.currentCreature.funfact;
        } else if (type === 'incorrect') {
          description = '答错啦！请重新试试哦';
        } else if (type === 'skipped') {
          description = '这是' + this.currentCreature.name + '，' + this.currentCreature.classification +
            '。栖息于' + this.currentCreature.habitat + '。特征：' + this.currentCreature.characteristics +
            '。习性：' + this.currentCreature.behavior + '。有趣的是：' + this.currentCreature.funfact;
        }
        if (description) this.speakWithChildVoice(description);
        this.modalVisible = true;
      },

      closeModal: function () {
        if (window.speechSynthesis) window.speechSynthesis.cancel();
        var animationContainer = this.$refs.animationContainer;
        if (animationContainer) {
          animationContainer.style.animationPlayState = 'paused';
          animationContainer.style.display = 'none';
        }
        this.modalVisible = false;
        if (this.modalType === 'skipped') {
          this.nextRound();
        }
      },

      nextRound: function () {
        if (window.speechSynthesis) window.speechSynthesis.cancel();
        this.modalVisible = false;
        this.round++;

        if (this.round > this.maxRounds) {
          var finalScore = Math.round((this.score / (this.maxRounds * 10)) * 100);
          var msg = '<div style="text-align: center; margin-bottom: 16px;">' +
            '<div style="font-size: 1.2em; margin-bottom: 8px;">游戏结束！</div>' +
            '<div>你的最终得分是: <span style="color: #ffcc00; font-weight: bold;">' +
            this.score + '/' + (this.maxRounds * 10) + '</span> (' + finalScore + '分)</div></div>';
          if (finalScore >= 90) {
            msg += '<div style="color: #4CAF50; font-weight: bold; text-align: center; margin: 12px 0;">太棒了！你是海洋生物专家！</div>';
          } else if (finalScore >= 70) {
            msg += '<div style="color: #4CAF50; text-align: center; margin: 12px 0;">做得不错！你对海洋生物很了解！</div>';
          } else if (finalScore >= 50) {
            msg += '<div style="text-align: center; margin: 12px 0;">还不错！继续学习海洋知识吧！</div>';
          } else {
            msg += '<div style="text-align: center; margin: 12px 0;">加油！多了解海洋生物会有更好表现！</div>';
          }
          this.showModal('游戏结束', msg, 'gameover', null);
          return;
        }
        this.startNewRound();
      },

      restartGame: function () {
        this.modalVisible = false;
        this.score = 0;
        this.round = 1;
        this.usedCreatures = [];
        this.startNewRound();
        this.$message({ message: '新游戏开始！', type: 'success', duration: 2000 });
      }
    }
  });

  // 页面销毁前停止语音
  window.addEventListener('beforeunload', function () {
    if (window.speechSynthesis) window.speechSynthesis.cancel();
  });
</script>
</body>
</html>
