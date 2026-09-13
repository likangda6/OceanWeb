<template>
  <div class="body ai-page">
    <app-navbar :active="'ai'" />
    <div id="appChat" class="center-body" v-cloak>
      <div class="sprite-animation"></div>
      <div class="chat-window">
        <div class="box">
          <div class="chat-content" ref="chatContent">
            <div class="current-time">{{ currentTime }}</div>
            <div class="top">
              <div class="top-image"></div>
              <div class="top-text">您好，粉章泡泡正在为您服务</div>
              <el-tooltip content="清空对话记录" placement="top">
                <i class="el-icon-delete clear-history-btn" @click="clearChatHistory"></i>
              </el-tooltip>
            </div>

            <div class="ai-message" :class="msg.role === 'user' ? 'msg-right' : 'msg-left'" v-for="(msg, i) in messages" :key="i">
              <div class="ai-text" v-if="msg.role === 'ai'" v-html="msg.html || msg.content"></div>
              <div class="user-text" v-else>
                <img v-if="msg.image" :src="msg.image" class="msg-image" alt="附件">
                <div>{{ msg.content }}</div>
              </div>
            </div>

            <div class="hot-questions" v-if="messages.length <= 1">
              <h3>热门问题</h3>
              <div class="question-tags">
                <el-tag v-for="(q, i) in currentQuestions" :key="i"
                        class="question-tag"
                        @click.native="askQuestion(q)">
                  {{ q }}
                </el-tag>
              </div>
              <el-button size="mini" round class="refresh-btn" @click="refreshQuestions">
                换一批
              </el-button>
            </div>
          </div>
          <div class="input-area">
            <div class="input-top">
              <el-tooltip :content="ttsEnabled ? '点击关闭朗读' : '点击开启朗读'" placement="top">
                <div class="tts-control" @click="toggleTts">
                  <img :src="ttsEnabled ? '/images/ai/sound.png' : '/images/ai/noSound.png'" class="sound" alt="">
                </div>
              </el-tooltip>
              <el-tooltip content="点击说话" placement="top">
                <div class="recording-control" @click="toggleRecording">
                  <img :src="isRecording ? '/images/ai/recording.png' : '/images/ai/record.png'" class="sound" alt="">
                </div>
              </el-tooltip>
              <el-tooltip content="上传图片提问" placement="top">
                <div class="image-control" @click="triggerImageInput">
                  <i class="el-icon-picture-outline"></i>
                </div>
              </el-tooltip>
              <input type="file" ref="imageInput" accept="image/*" style="display:none;" @change="handleImageChange">
            </div>
            <div class="image-preview" v-if="attachedImage">
              <img :src="attachedImagePreview" class="preview-thumb" alt="预览">
              <span class="preview-name">{{ attachedImageName }}</span>
              <i class="el-icon-close preview-remove" @click="clearAttachedImage"></i>
            </div>
            <div class="input-container">
              <el-input v-model="userInput" type="textarea" :autosize="{ minRows: 1, maxRows: 4 }"
                        placeholder="请输入您关于海洋生物的问题"
                        @keydown.enter.native.prevent="sendMessage"
                        id="userInput" resize="none"></el-input>
              <div class="send-btn" :class="{ active: userInput.trim() || attachedImage }" @click="sendMessage"></div>
            </div>
            <div class="input-hint">shift+enter换行，enter发送{{ attachedImage ? '（已附图片）' : '' }}</div>
          </div>
        </div>
      </div>
      <div class="notice">
        <div class="notice1">
          <div class="notice1-title">
            <img src="/images/ai/notice1.png" class="notice-img" alt="">
            <div class="notice-title">公告</div>
          </div>
          <div class="content">
            您好！我是"鲸途知海"海洋生物图鉴的AI语音助手粉章泡泡，由团队倾力打造，集成了全球权威海洋生物数据库和最新科研成果。我能为您提供3000+种海洋生物的详细资料、生态特征和保护知识，是您探索海洋世界的智能向导。
          </div>
        </div>
        <div class="notice3">
          <div class="notice1-title">
            <img src="/images/ai/oceanWeb.png" class="notice-img" alt="">
            <div class="notice-title">海洋资源</div>
          </div>
          <div class="dataSourse">
            <div @click="openExternal('https://www.catalogueoflife.org')" style="cursor: pointer;">
              <div class="images"><img src="/images/ai/COL.png" alt=""></div>
              <div class="images-title">世界物种名录</div>
            </div>
            <div @click="openExternal('https://www.marinespecies.org')" style="cursor: pointer;">
              <div class="images"><img src="/images/ai/WORMS.png" alt=""></div>
              <div class="images-title">海洋物种名录</div>
            </div>
            <div @click="openExternal('https://www.iucnredlist.org')" style="cursor: pointer;">
              <div class="images"><img src="/images/ai/IUCN.png" alt=""></div>
              <div class="images-title">IUCN红色名录</div>
            </div>
          </div>
        </div>
        <div class="notice2">
          <div class="notice1-title">
            <img src="/images/ai/question.png" class="notice-img" alt="">
            <div class="notice-title">常见问题</div>
          </div>
          <div class="content1">
            <div class="content-wrapper">
              <div class="question-content" v-for="(q, i) in commonQuestions" :key="i" @click="askQuestion(q)">{{ q }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import AppNavbar from '@/components/Navbar.vue';
import { marked } from 'marked';
import http, { getToken } from '@/utils/auth.js';
import { isLoggedIn } from '@/utils/auth.js';

export default {
  name: 'AiRobot',
  components: { AppNavbar },
  data() {
    return {
      messages: [{
        role: 'ai',
        content: '你好！我是"鲸途知海"海洋生物AI助手"粉章泡泡"，我可以为您解答关于海洋生物的各种问题，包括物种特征、栖息地、保护现状等，让我们一起探索神奇的海洋世界吧！'
      }],
      userInput: '',
      currentTime: '',
      ttsEnabled: true,
      isSpeaking: false,
      isRecording: false,
      currentUtterance: null,
      currentQuestions: ["鲸鱼种类", "珊瑚白化", "深海生物", "海洋保护", "海龟生命周期", "发光生物"],
      commonQuestions: ["鲸鱼有多大", "珊瑚是动物吗", "最深的海洋生物", "如何保护海洋", "海龟的寿命", "会发光的鱼"],
      questionGroups: [
        ["鲸鱼种类", "珊瑚白化", "深海生物", "海洋保护", "海龟生命周期", "发光生物"],
        ["最大的海洋生物", "最深的海洋生物", "海洋食物链", "珊瑚礁生态系统", "海洋污染", "塑料对海洋的影响"],
        ["海豚智商", "鲨鱼种类", "章鱼有几颗心", "水母会游泳吗", "海洋生物发光原理", "如何保护珊瑚礁"]
      ],
      currentGroupIndex: 0,
      recognition: null,
      isPermissionGranted: false,
      spriteEl: null,
      attachedImage: null,
      attachedImagePreview: '',
      attachedImageName: ''
    };
  },
  computed: {},
  mounted: function () {
    var self = this;
    this.spriteEl = document.querySelector('.sprite-animation');
    if (this.spriteEl) this.spriteEl.style.animationPlayState = 'paused';
    this.updateCurrentTime();
    setInterval(function () { self.updateCurrentTime(); }, 1000);
    this.initSpeechRecognition();
    // 页面加载后朗读欢迎语
    var _this = this;
    setTimeout(function () {
      if (_this.ttsEnabled) _this.speakWithChildVoice('你好呀！我是粉章泡泡，很高兴为你服务~');
    }, 200);
    // 加载历史对话记录（需登录）
    this.loadHistory();
  },
  methods: {
    updateCurrentTime: function () {
      var now = new Date();
      var pad = function (n) { return String(n).padStart(2, '0'); };
      this.currentTime = pad(now.getMonth() + 1) + '/' + pad(now.getDate()) + ' ' +
        pad(now.getHours()) + ':' + pad(now.getMinutes()) + ':' + pad(now.getSeconds());
    },
    // 从后端加载历史对话记录
    loadHistory: function () {
      if (!isLoggedIn()) return;
      var self = this;
      http.get('/ai/history').then(function (res) {
        var data = res.data;
        if (data.code === 200 && data.data && Array.isArray(data.data)) {
          // 清除默认欢迎语，用历史记录填充
          self.messages = [];
          data.data.forEach(function (item) {
            // 用户消息
            self.messages.push({
              role: 'user',
              content: item.userMessage,
              image: item.imageUrl || ''
            });
            // AI 消息
            self.messages.push({
              role: 'ai',
              content: item.aiMessage,
              html: marked.parse(item.aiMessage || '')
            });
          });
          if (self.messages.length === 0) {
            self.messages.push({
              role: 'ai',
              content: '你好！我是"鲸途知海"海洋生物AI助手"粉章泡泡"，我可以为您解答关于海洋生物的各种问题。'
            });
          }
          self.$nextTick(function () { self.scrollChatToBottom(); });
        }
      }).catch(function (err) {
        console.error('加载历史记录失败:', err);
      });
    },
    // 清空历史记录
    clearChatHistory: function () {
      var self = this;
      this.$confirm('确定要清空所有对话记录吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(function () {
        http.delete('/ai/history').then(function (res) {
          self.$message.success('已清空');
          self.messages = [{
            role: 'ai',
            content: '你好！我是"鲸途知海"海洋生物AI助手"粉章泡泡"，我可以为您解答关于海洋生物的各种问题。'
          }];
        }).catch(function () {
          self.$message.error('清空失败');
        });
      }).catch(function () {});
    },
    openExternal: function (url) { window.open(url, '_blank'); },
    askQuestion: function (q) {
      this.userInput = q;
      var self = this;
      this.$nextTick(function () { self.sendMessage(); });
    },
    refreshQuestions: function () {
      this.currentGroupIndex = (this.currentGroupIndex + 1) % this.questionGroups.length;
      this.currentQuestions = this.questionGroups[this.currentGroupIndex];
    },
    sendMessage: function () {
      var message = this.userInput.trim();
      var hasImage = !!this.attachedImage;
      if (!message && !hasImage) return;

      // 如果没有文本但有图片，给一个默认问题
      if (!message && hasImage) {
        message = '请识别这张图片中的海洋生物';
      }

      // 用户消息（含图片预览）
      var userMsg = { role: 'user', content: message };
      if (hasImage) {
        userMsg.image = this.attachedImagePreview;
      }
      var userMsgIdx = this.messages.push(userMsg) - 1;
      this.userInput = '';

      // 保存当前图片引用，然后清除附件
      var currentImage = this.attachedImage;
      this.clearAttachedImage();

      var self = this;
      this.$nextTick(function () { self.scrollChatToBottom(); });

      if (hasImage) {
        // 带图片 → 调用多模态接口（传入用户消息索引，便于回写 MinIO 图片地址）
        this.callMultimodalAPI(message, currentImage, userMsgIdx);
      } else {
        // 纯文本 → 静态回复或流式
        var staticResp = this.getStaticResponse(message);
        if (staticResp) {
          this.showStaticResponse(staticResp);
        } else {
          this.callStreamingAPI(message);
        }
      }
    },
    triggerImageInput: function () {
      this.$refs.imageInput.click();
    },
    handleImageChange: function (e) {
      var file = e.target.files[0];
      if (!file) return;
      if (!file.type.startsWith('image/')) {
        this.$message.error('请选择图片文件');
        return;
      }
      if (file.size > 4 * 1024 * 1024) {
        this.$message.error('图片不能超过4MB');
        return;
      }
      this.attachedImage = file;
      this.attachedImageName = file.name;
      var self = this;
      var reader = new FileReader();
      reader.onload = function (ev) {
        self.attachedImagePreview = ev.target.result;
      };
      reader.readAsDataURL(file);
      // 重置 input 以便重复选择同一文件
      e.target.value = '';
    },
    clearAttachedImage: function () {
      this.attachedImage = null;
      this.attachedImagePreview = '';
      this.attachedImageName = '';
    },
    callMultimodalAPI: function (question, imageFile, userMsgIdx) {
      var self = this;
      var msgIdx = this.messages.push({ role: 'ai', content: '', html: '' }) - 1;

      var formData = new FormData();
      formData.append('question', question);
      if (imageFile) {
        formData.append('image', imageFile);
      }

      http.post('/ai/chatWithImage', formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      })
        .then(function (res) {
          var data = res.data;
          if (data.code === 200 && data.data && data.data.answer) {
            var answer = data.data.answer;
            // 后端返回 MinIO 持久化图片地址，替换本地预览（blob/dataURL），
            // 刷新页面加载历史时图片仍可访问
            if (data.data.imageUrl && userMsgIdx != null) {
              self.$set(self.messages[userMsgIdx], 'image', data.data.imageUrl);
            }
            self.$set(self.messages, msgIdx, {
              role: 'ai',
              content: answer,
              html: marked.parse(answer)
            });
            self.scrollChatToBottom();
            if (self.ttsEnabled) self.speakWithChildVoice(answer);
          } else {
            self.$set(self.messages, msgIdx, {
              role: 'ai',
              content: data.message || '回答失败，请稍后再试'
            });
          }
        })
        .catch(function (err) {
          console.error('多模态对话失败:', err);
          self.$set(self.messages, msgIdx, {
            role: 'ai',
            content: '网络连接出现问题，请稍后再试'
          });
        });
    },
    scrollChatToBottom: function () {
      var el = this.$refs.chatContent;
      if (el) el.scrollTop = el.scrollHeight;
    },
    getStaticResponse: function (question) {
      var responses = {
        "鲸鱼种类": "目前已知的鲸类动物约有90种，主要分为两大类：须鲸亚目（如蓝鲸、座头鲸）和齿鲸亚目（如虎鲸、抹香鲸）。蓝鲸是地球上已知最大的动物，体长可达33米！",
        "珊瑚白化": "珊瑚白化是珊瑚因环境压力（如水温升高）排出体内共生的虫黄藻而变白的现象。持续白化会导致珊瑚死亡，威胁整个珊瑚礁生态系统。",
        "深海生物": "深海是地球上最大的生态系统，生活着许多奇特生物，如发光鱿鱼、深海鮟鱇鱼、管水母等。它们大多具有发光器官、巨大嘴巴等适应黑暗环境的特征。",
        "海洋保护": "保护海洋可以从减少塑料使用、选择可持续海鲜、支持海洋保护区、参与海滩清洁和减少碳排放等方面做起。",
        "海龟生命周期": "海龟寿命可达80年以上！它们会洄游数千公里回到出生地繁殖，幼龟孵化后要经历艰难的死亡奔跑才能到达大海。",
        "发光生物": "约90%的深海生物能生物发光，主要用于诱捕猎物、迷惑天敌和求偶交流。最著名的有萤光藻、发光水母和灯笼鱼等。",
        "最大的海洋生物": "蓝鲸是已知最大的海洋生物，也是地球史上最大的动物，成年体长可达33米，重达200吨，仅舌头就有一头大象那么重！",
        "最深的海洋生物": "在马里亚纳海沟11000米深处发现有狮子鱼生存，是目前已知栖息地最深的鱼类。它们体内充满特殊蛋白质来抵抗高压。",
        "海洋食物链": "海洋食物链从微小的浮游植物开始，到大型掠食者结束。关键环节包括：浮游植物→浮游动物→小鱼→大型鱼类→顶级掠食者（如鲨鱼、鲸类）。",
        "珊瑚礁生态系统": "珊瑚礁被称为海洋热带雨林，虽然只占海底面积的0.1%，却养育着25%的海洋物种，是生物多样性最丰富的海洋生态系统。",
        "海洋污染": "每年约有800万吨塑料进入海洋，形成塑料汤。这些塑料会被海洋生物误食，最终可能通过食物链回到人类体内。",
        "塑料对海洋的影响": "塑料污染每年导致超过100万海洋生物死亡。微塑料已进入海洋食物链，甚至在最深的马里亚纳海沟生物体内也被发现。",
        "海豚智商": "海豚是除人类外最聪明的动物之一，大脑与体重比仅次于人类，具有自我意识、复杂社会结构和独特的交流系统。",
        "鲨鱼种类": "现存鲨鱼约有500种，从仅17厘米长的侏儒灯笼鲨到18米长的鲸鲨不等。80%的鲨鱼体长不足1.6米，只有少数种类会攻击人类。",
        "章鱼有几颗心": "章鱼有三颗心脏！两颗专门负责将血液输送到鳃，第三颗负责输送到全身。当章鱼游泳时，负责全身供血的心脏会停止跳动。",
        "水母会游泳吗": "大多数水母只能随波逐流，但有些种类如箱水母可以主动游泳，速度可达每小时6公里！它们的游泳其实是收缩伞状体喷水推进。",
        "海洋生物发光原理": "生物发光是通过荧光素和荧光素酶的化学反应产生，能量转化效率高达95%（普通灯泡仅5%）。不同生物发光颜色各异，从蓝绿到红色都有。",
        "如何保护珊瑚礁": "保护珊瑚礁可以：1.使用环保防晒霜 2.潜水时不触碰珊瑚 3.减少碳排放 4.支持可持续渔业 5.参与珊瑚种植活动。",
        "鲸鱼有多大": "蓝鲸是最大的鲸类，体长可达33米，相当于3辆校车首尾相连！最小的鲸类是江豚，只有1.5米左右。不同鲸类大小差异很大。",
        "珊瑚是动物吗": "是的！珊瑚是由成千上万的珊瑚虫组成的动物群体。它们虽然看起来像植物或石头，但其实是刺胞动物门的一员，与水母是近亲。"
      };
      return responses[question];
    },
    showStaticResponse: function (response) {
      var self = this;
      // 添加空 AI 消息占位
      var msgIdx = this.messages.push({ role: 'ai', content: '', typingIndex: 0 }) - 1;
      var index = 0;
      var typingSpeed = 30;
      function typeWriter() {
        if (index < response.length) {
          index++;
          self.$set(self.messages, msgIdx, { role: 'ai', content: response.substring(0, index), typingIndex: index });
          self.scrollChatToBottom();
          setTimeout(typeWriter, typingSpeed);
        } else {
          if (self.ttsEnabled) self.speakWithChildVoice(response);
        }
      }
      typeWriter();
    },
    callStreamingAPI: function (question) {
      var self = this;
      var msgIdx = this.messages.push({ role: 'ai', content: '', html: '' }) - 1;
      var fullResponse = '';
      // 浏览器原生 EventSource 无法设置请求头，将 token 作为 query 参数传递
      // 后端 JwtAuthenticationFilter 会回退到 token query 参数进行认证
      var sseUrl = '/ai/chatStream?question=' + encodeURIComponent(question);
      var token = getToken();
      if (token) {
        sseUrl += '&token=' + encodeURIComponent(token);
      }
      var eventSource = new EventSource(sseUrl);
      eventSource.onmessage = function (event) {
        try {
          var data = JSON.parse(event.data);
          if (data && data.choices && data.choices[0] && data.choices[0].delta && data.choices[0].delta.content) {
            fullResponse += data.choices[0].delta.content;
            self.$set(self.messages, msgIdx, { role: 'ai', content: fullResponse, html: marked.parse(fullResponse) });
            self.scrollChatToBottom();
          }
        } catch (e) { console.error('解析SSE数据出错:', e); }
      };
      eventSource.onerror = function () {
        eventSource.close();
        if (!fullResponse) {
          self.$set(self.messages, msgIdx, { role: 'ai', content: '网络连接出现问题，请稍后再试' });
        }
        if (self.ttsEnabled && fullResponse) self.speakWithChildVoice(fullResponse);
      };
    },
    // === 语音合成（TTS） ===
    filterMarkdown: function (text) {
      text = text.replace(/~~/g, '');
      text = text.replace(/[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]/gu, '')
        .replace(/[\u{2460}-\u{2473}]/gu, '')
        .replace(/[\u{3251}-\u{325F}]/gu, '')
        .replace(/[\u{32B1}-\u{32BF}]/gu, '')
        .replace(/[\u{24EA}\u{24FF}]/gu, '')
        .replace(/[\u{2776}-\u{2793}]/gu, '')
        .replace(/[◆★☆▪▫■□●○►◄▲▼➤⚡♥♦♣♠]/g, '')
        .replace(/\s+/g, ' ')
        .replace(/\([^)]*图标[^)]*\)/gi, '')
        .trim();
      text = text.replace(/^#+\s+/gm, '');
      text = text.replace(/(\*{1,2}|_{1,2})(.*?)\1/g, '$2');
      text = text.replace(/`{1,3}/g, '');
      text = text.replace(/\[(.*?)\]\(.*?\)/g, '$1');
      text = text.replace(/<[^>]*>/g, '');
      return text;
    },
    speakWithChildVoice: function (text) {
      if (!this.ttsEnabled || !window.speechSynthesis) return;
      var self = this;
      try {
        // 先取消之前所有朗读，允许新回答打断旧朗读
        window.speechSynthesis.cancel();
        this.isSpeaking = false;
        var cleanText = this.filterMarkdown(text);
        if (!cleanText) { return; }
        var utterance = new SpeechSynthesisUtterance(cleanText);
        utterance.lang = 'zh-CN';
        utterance.rate = 1.1;
        utterance.pitch = 1.8;
        utterance.volume = 0.9;
        var voices = window.speechSynthesis.getVoices();
        var childVoices = voices.filter(function (v) {
          return v.lang.includes('zh') && (
            v.name.includes('Mei-Jia') || v.name.includes('TingTing') ||
            v.name.includes('Child') || v.name.includes('Xiaoxiao')
          );
        });
        if (childVoices.length > 0) utterance.voice = childVoices[0];
        else {
          var chineseVoices = voices.filter(function (v) { return v.lang.includes('zh'); });
          if (chineseVoices.length) {
            utterance.voice = chineseVoices.reduce(function (a, b) {
              return (a.name.includes('Female') ? 1 : 0) > (b.name.includes('Female') ? 1 : 0) ? a : b;
            });
          }
        }
        // isSpeaking 在 onstart 才设 true，避免 cancel() 触发的旧 onend 异步覆盖状态
        utterance.onstart = function () {
          self.isSpeaking = true;
          if (self.spriteEl) self.spriteEl.style.animationPlayState = 'running';
        };
        utterance.onend = utterance.onerror = function () {
          if (self.spriteEl) self.spriteEl.style.animationPlayState = 'paused';
          self.isSpeaking = false;
        };
        this.currentUtterance = utterance;
        window.speechSynthesis.speak(utterance);
      } catch (e) {
        console.error('语音合成错误:', e);
        this.isSpeaking = false;
      }
    },
    toggleTts: function () {
      // 如果正在朗读，先停止再切换状态
      if (this.isSpeaking) {
        window.speechSynthesis.cancel();
        this.isSpeaking = false;
        if (this.spriteEl) this.spriteEl.style.animationPlayState = 'paused';
        this.ttsEnabled = false;
        return;
      }
      this.ttsEnabled = !this.ttsEnabled;
      if (this.ttsEnabled) {
        // 朗读最后一条 AI 消息
        var last = null;
        for (var i = this.messages.length - 1; i >= 0; i--) {
          if (this.messages[i].role === 'ai') { last = this.messages[i]; break; }
        }
        if (last) this.speakWithChildVoice(last.content);
      } else {
        window.speechSynthesis.cancel();
        if (this.spriteEl) this.spriteEl.style.animationPlayState = 'paused';
      }
    },
    // === 语音识别（录音） ===
    initSpeechRecognition: function () {
      var self = this;
      if (!('webkitSpeechRecognition' in window) && !('SpeechRecognition' in window)) return;
      var SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
      this.recognition = new SpeechRecognition();
      this.recognition.lang = 'zh-CN';
      this.recognition.interimResults = false;
      this.recognition.maxAlternatives = 1;
      this.recognition.onstart = function () {
        self.isRecording = true;
        self.isPermissionGranted = true;
      };
      this.recognition.onresult = function (event) {
        var transcript = event.results[0][0].transcript;
        self.userInput = transcript;
        self.isRecording = false;
      };
      this.recognition.onend = function () { self.isRecording = false; };
      this.recognition.onerror = function (event) {
        console.error('语音识别错误:', event.error);
        self.isRecording = false;
      };
    },
    toggleRecording: function () {
      if (!this.recognition) {
        this.$message({ message: '您的浏览器不支持语音识别', type: 'warning' });
        return;
      }
      if (!this.isRecording) {
        this.recognition.start();
      } else {
        this.recognition.stop();
      }
    }
  }
};
</script>

<style scoped>
[v-cloak] { display: none; }
.body {
  margin: 0;
  padding: 0;
  width: 100%;
  min-height: 100vh;
  font-family: 'Microsoft YaHei', Arial, sans-serif;
}
.ai-page {
  background-image: url('/images/888.png');
  background-size: cover;
  overflow: hidden;
}

.navbar {
  display: flex;
  overflow: hidden;
  background-color: rgba(255, 255, 255, 0.40);
  padding: 2vh 0;
}

.navbar a {
  color: white;
  padding: 1vw 2vh;
  text-decoration: none;
  text-align: center;
}

.dropdown {
  float: left;
  overflow: hidden;
}

.dropdown .dropbtn {
  cursor: pointer;
  width: 9vw;
  height: 8vh;
  font-size: 1.2vw;
  line-height: 1.2vw;
  font-family: 'Gill Sans', 'Gill Sans MT', Calibri, 'Trebuchet MS', sans-serif;
  font-weight: 500;
  border: none;
  outline: none;
  color: white;
  text-align: center;
  background-color: inherit;
  font-family: inherit;
  margin: 0;
}

.dropbtn:hover,
.dropdown:hover .dropbtn {
  color: yellow
}

.changed {
  border-bottom: 0.5vh solid orange;
}

.navbar a:hover,
.dropbtn {
  background-color: #ddd;
}

.dropdown:hover {
  display: block;
}

.login-status {
  display: flex;
  align-items: center;
}

.login-status img {
  width: 1.6vw;
  height: 1.6vw;
  border-radius: 50%;
  margin-right: 1vw;
}

.login-status span {
  color: white;
  padding: 1vw 2vh;
}

.right {
  position: absolute;
  right: 0;
  width: 15vw;
  height: 8vh;
  line-height: 8vh;
  color: white;
  display: flex;
}

.right img {
  width: 5vh;
  height: 5vh;
  margin: auto;
}

.title {
  width: 10vw;
  height: 100%;
  background-color: aqua;
}

.library-name {
  margin-left: 3vw;
  display: flex;
  justify-content: center;
  align-items: center;
}

.library-title {
  margin-left: 1vw;
  font-family: 楷体;
  font-weight: 800;
  color: black;
  text-shadow: 3px 3px 5px rgba(139, 137, 137, 0.3);
  font-weight: 300;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.center-body {
  width: 100%;
  height: 80%;
  display: flex;
  margin-top: 5vh;
}

.sprite-animation {
  margin-top: 5vh;
  width: 500px;
  height: 600px;
  background-image: url("/images/7771.png");
  background-repeat: no-repeat;
  animation: play-sprite 6s steps(100) infinite;
}

@keyframes play-sprite {
  0% {
    background-position: 0 0;
  }

  100% {
    background-position: -50000px 0;
  }
}

.chat-window {
  width: 40vw;
  height: 82vh;
  background-color: rgb(249, 249, 249, 0);
}

.box {
  width: 38vw;
  height: 100%;
  max-height: 100%;
  background-color: rgb(249, 249, 249, 0);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.chat-header {
  background-color: #1a56a7;
  color: white;
  padding: 15px 20px;
  text-align: center;
  font-size: 18px;
  font-weight: bold;
}

.chat-content {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
  background-color: rgb(249, 249, 249, 0);
  scrollbar-color: rgba(0, 9, 20, 0.5) transparent;
}

.chat-content::-webkit-scrollbar {
  width: 12px;
}

.chat-content::-webkit-scrollbar-track {
  background: transparent;
}

.chat-content::-webkit-scrollbar-button {
  display: none;
  width: 0;
  height: 0;
}

.ai-message {
  display: flex;
  margin-bottom: 15px;
}

/* AI 消息靠左 */
.msg-left {
  justify-content: flex-start;
}

/* 用户消息靠右 */
.msg-right {
  justify-content: flex-end;
}

.ai-text {
  max-width: 80%;
  background-color: white;
  padding: 12px 15px;
  border-radius: 0 15px 15px 15px;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
}

.user-text {
  max-width: 80%;
  background-color: #3f97ec;
  color: white;
  padding: 12px 15px;
  border-radius: 15px 0 15px 15px;
}

.hot-questions {
  width: 80%;
  margin-top: 20px;
  background-color: rgba(224, 247, 255, 0.5);
  border-radius: 12px;
  padding: 10px;
  margin-bottom: 10px;
  text-align: center;
}

.hot-questions h3 {
  line-height: 20px;
  font-size: 18px;
  color: black;
  margin: 0;
}

.question-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  justify-content: center;
  margin-top: 10px;
}

.question-tag {
  background-color: white;
  border: 1px solid #ddd;
  border-radius: 20px;
  padding: 8px 15px;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s;
}

.question-tag:hover {
  background-color: #1a56a7;
  color: white;
  border-color: #1a56a7;
}

.refresh-btn {
  color: #1a56a7;
  font-size: 14px;
  margin-top: 10px;
  cursor: pointer;
  display: block;
  position: relative;
  left: calc(100% - 90px);
  width: fit-content;
  padding: 5px 10px;
  border: 1px solid #1a56a7;
  border-radius: 5px;
  transition: background-color 0.3s, color 0.3s;
}

.refresh-btn:hover {
  background-color: #1a56a7;
  color: white;
}

.input-area {
  padding: 15px;
  background-image: url("/images/ai/fish1.png");
  background-size: 100% 100%;
}

.input-container {
  width: 85%;
  margin: auto;
  display: flex;
  align-items: center;
  background-color: white;
  border-radius: 25px;
  padding: 5px 20px;
  align-items: flex-end;
}

.input-container textarea {
  flex: 1;
  border: none;
  background: transparent;
  padding: 10px;
  outline: none;
  font-size: 15px;
  font-family: inherit;
  resize: none;
  max-height: 100px;
  line-height: 1.4;
  scrollbar-width: none;
  -ms-overflow-style: none;
}

.input-container textarea::-webkit-scrollbar {
  display: none;
  width: 0;
  height: 0;
}

.send-btn {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background-image: url("/images/ai/sendButton1.png");
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
  font-weight: bold;
  cursor: pointer;
  flex-shrink: 0;
}

/* 有输入内容或附加图片时切换为高亮发送图标 */
.send-btn.active {
  background-image: url("/images/ai/sendButton.png");
}

.input-hint {
  font-size: 12px;
  color: white;
  margin-top: 5px;
  text-align: right;
}

.current-time {
  width: 200px;
  height: 18px;
  line-height: 18px;
  text-align: center;
  font-size: 12px;
  color: white;
  margin: 0 auto;
}

.top {
  width: 200px;
  height: 45px;
  background-color: white;
  border-radius: 10px;
  margin: 25px auto;
  display: flex;
  flex-direction: column;
  position: relative;
}

.top-image {
  width: 40px;
  height: 40px;
  background: url("/images/ai/aa.png") center/cover no-repeat;
  border-radius: 50%;
  margin: 0 auto;
  position: absolute;
  top: -20px;
  left: 50%;
  transform: translateX(-50%);
  z-index: 1;
}

.top-text {
  width: 200px;
  height: 50px;
  border-radius: 10px;
  flex-shrink: 0;
  margin-top: 5px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: rgb(0, 0, 0);
  font-size: 12px;
}

.clear-history-btn {
  position: absolute;
  right: 10px;
  top: 15px;
  font-size: 18px;
  color: #f56c6c;
  cursor: pointer;
  transition: all 0.3s;
}

.clear-history-btn:hover {
  color: #f78989;
  transform: scale(1.2);
}

.notice {
  width: 26vw;
  height: 72vh;
  padding: 20px;
}

.notice1 {
  width: 26vw;
  height: 22vh;
  background-color: #96d9f3;
  border: 2px solid white;
  margin: 0 auto;
  border-radius: 10px;
}

.notice1-title {
  width: 100%;
  height: 5.5vh;
  border-bottom: 1px solid rgb(7, 135, 204);
  display: flex;
  align-items: center;
  justify-content: center;
}

.notice-img {
  width: 30px;
  height: 30px;
}

.notice-title {
  font-size: 19px;
  font-weight: 600;
  margin-left: 5px;
}

.content {
  width: 90%;
  height: 70%;
  margin: 0 auto;
  padding: 10px;
  font-size: 16px;
}

.notice2 {
  width: 26vw;
  height: 29vh;
  background-color: #96d9f3;
  border: 2px solid white;
  margin: 30px auto;
  border-radius: 10px;
  overflow: hidden;
  position: relative;
}

.content1 {
  width: 90%;
  height: calc(100% - 50px);
  margin: 0 auto;
  padding: 10px;
  display: flex;
  flex-direction: column;
  align-items: center;
  overflow-y: hidden;
  scrollbar-width: none;
  -ms-overflow-style: none;
}

.content::-webkit-scrollbar {
  display: none;
}

.question-content {
  width: 14vw;
  text-align: center;
  line-height: 4vh;
  height: 4vh;
  cursor: pointer;
  transition: all 0.3s;
  will-change: transform, box-shadow, z-index;
  backface-visibility: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #333;
  font-size: 20px;
  border-radius: 5px;
  background-color: rgba(255, 255, 255, 0.8);
  box-shadow: 0 0 0 rgba(0, 0, 0, 0);
  margin-top: 0.5vh;
}

.question-content:hover {
  color: #ff6b6b;
}

@keyframes scrollAnimation {
  from {
    transform: translateY(0);
  }
  to {
    transform: translateY(-50%);
  }
}

.content-wrapper {
  animation: scrollAnimation 10s linear infinite;
  display: flex;
  flex-direction: column;
}

.notice3 {
  width: 26vw;
  height: 16vh;
  background-color: #96d9f3;
  border: 2px solid white;
  margin: 30px auto;
  border-radius: 10px;
}

.dataSourse {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 12px;
}

.dataSourse > div {
  width: 50%;
  height: 65%;
  margin-bottom: 20px;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.images {
  background-color: rgb(8, 78, 52);
  width: 80%;
  height: 48%;
}

.images > img {
  width: 100%;
  height: 100%;
  object-fit: fill;
}

.images-title {
  margin-top: 5px;
  color: rgb(75, 74, 74);
  font-size: 14px;
}

.images img {
  transition: transform 0.3s ease;
}

.images:hover img {
  transform: scale(1.05);
}

/* 新增的朗读控制按钮样式 */
.tts-control {
  width: 25px;
  height: 25px;
  margin-bottom: 10px;
  border-radius: 50%;
  background-color: white;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
  z-index: 1000;
  border: none;
  transition: all 0.3s;
}

.tts-control:hover {
  transform: scale(1.1);
}

.tts-control:active {
  transform: scale(0.95);
}

.sound {
  width: 20px;
  height: 20px;
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
}

.input-top {
  display: flex;
  margin: auto;
  width: 18%;
  height: 25px;
  padding-top: 8px;
  padding-bottom: 2px;
  justify-content: space-around;
}

.recording-control {
  width: 25px;
  height: 25px;
  margin-left: 10px;
  margin-bottom: 10px;
  border-radius: 50%;
  background-color: white;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
  z-index: 1000;
  border: none;
  transition: all 0.3s;
}

.recording-control:hover {
  transform: scale(1.1);
}

.recording-control:active {
  transform: scale(0.95);
}

/* 图片上传按钮 */
.image-control {
  width: 25px;
  height: 25px;
  margin-left: 10px;
  margin-bottom: 10px;
  border-radius: 50%;
  background-color: white;
  color: #1a56a7;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
  z-index: 1000;
  border: none;
  transition: all 0.3s;
  font-size: 14px;
}

.image-control:hover {
  transform: scale(1.1);
}

.image-control:active {
  transform: scale(0.95);
}

/* 图片预览条 */
.image-preview {
  display: flex;
  align-items: center;
  width: 85%;
  margin: 5px auto;
  padding: 6px 10px;
  background-color: rgba(255, 255, 255, 0.9);
  border-radius: 8px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.1);
}

.preview-thumb {
  width: 40px;
  height: 40px;
  object-fit: cover;
  border-radius: 4px;
  margin-right: 8px;
}

.preview-name {
  flex: 1;
  font-size: 13px;
  color: #333;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.preview-remove {
  cursor: pointer;
  color: #f56c6c;
  font-size: 18px;
  margin-left: 8px;
}

.preview-remove:hover {
  color: #f78989;
}

/* 聊天消息中的图片 */
.msg-image {
  max-width: 200px;
  max-height: 200px;
  border-radius: 8px;
  margin-bottom: 8px;
  display: block;
}

.ai-text del {
  text-decoration: none;
}
</style>
