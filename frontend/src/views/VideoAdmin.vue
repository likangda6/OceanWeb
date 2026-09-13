<template>
  <div class="body video-admin-page">
    <app-navbar :active="'videoAdmin'" />
    <div class="center-body">
      <div class="admin-container">
        <div class="admin-header">
          <h2 class="admin-title">视频管理</h2>
          <el-button type="primary" icon="el-icon-upload2" @click="showUploadDialog">上传视频</el-button>
        </div>
        <div class="search-bar">
          <el-input v-model="searchTitle" placeholder="搜索视频标题" prefix-icon="el-icon-search" clearable
                    style="width: 200px; margin-right: 10px;" @clear="fetchList" @keyup.enter.native="fetchList"></el-input>
          <el-select v-model="searchCategory" placeholder="全部分类" clearable style="width: 150px; margin-right: 10px;" @change="fetchList">
            <el-option label="科普视频" value="科普视频"></el-option>
            <el-option label="记录片段" value="记录片段"></el-option>
          </el-select>
          <el-button type="primary" @click="fetchList">搜索</el-button>
        </div>
        <el-table :data="videos" v-loading="loading" border style="width: 100%; margin-top: 15px;" stripe>
          <el-table-column prop="id" label="ID" width="60"></el-table-column>
          <el-table-column prop="title" label="标题" min-width="150"></el-table-column>
          <el-table-column prop="category" label="分类" width="100">
            <template slot-scope="scope">
              <el-tag size="small">{{ scope.row.category }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="时长" width="80">
            <template slot-scope="scope">{{ formatDuration(scope.row.duration) }}</template>
          </el-table-column>
          <el-table-column label="状态" width="80">
            <template slot-scope="scope">
              <el-tag :type="scope.row.status === 1 ? 'success' : 'danger'" size="small">
                {{ scope.row.status === 1 ? '正常' : '下架' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="createdAt" label="创建时间" width="160">
            <template slot-scope="scope">{{ scope.row.createdAt ? scope.row.createdAt.replace('T', ' ').substring(0, 16) : '' }}</template>
          </el-table-column>
          <el-table-column label="操作" width="150" fixed="right">
            <template slot-scope="scope">
              <el-button size="mini" @click="showEditDialog(scope.row)">编辑</el-button>
              <el-button size="mini" type="danger" @click="handleDelete(scope.row)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
        <div class="pagination-wrap">
          <el-pagination
            background
            layout="total, prev, pager, next, jumper"
            :total="total"
            :page-size="pageSize"
            :current-page.sync="currentPage"
            @current-change="fetchList"
          ></el-pagination>
        </div>
      </div>
    </div>

    <!-- 上传对话框 -->
    <el-dialog title="上传视频" :visible.sync="uploadVisible" width="500px" :close-on-click-modal="false">
      <el-form :model="uploadForm" label-width="80px">
        <el-form-item label="标题">
          <el-input v-model="uploadForm.title" placeholder="请输入视频标题"></el-input>
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="uploadForm.description" type="textarea" :rows="3" placeholder="请输入视频描述（可选）"></el-input>
        </el-form-item>
        <el-form-item label="分类">
          <el-select v-model="uploadForm.category" style="width: 100%">
            <el-option label="科普视频" value="科普视频"></el-option>
            <el-option label="记录片段" value="记录片段"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="视频文件">
          <el-upload
            ref="uploadRef"
            action="#"
            :auto-upload="false"
            :limit="1"
            accept="video/*"
            :on-change="handleFileChange"
            :on-exceed="handleExceed"
            :disabled="uploading"
          >
            <el-button size="small" type="primary" :disabled="uploading">选择视频文件</el-button>
            <div slot="tip" class="el-upload__tip">支持 mp4/avi/mov 等格式</div>
          </el-upload>
        </el-form-item>
        <!-- 实时上传进度条 -->
        <div class="upload-progress-wrap" v-if="uploading || uploadProgress > 0">
          <div class="progress-header">
            <span class="progress-stage">{{ uploadStage }}</span>
            <span class="progress-percent">{{ uploadProgress }}%</span>
          </div>
          <el-progress
            :percentage="uploadProgress"
            :status="uploadProgressStatus"
            :stroke-width="14"
            :text-inside="true"
            :show-text="false"
          ></el-progress>
          <div class="progress-detail">
            <span v-if="uploadedBytes && totalBytes">
              {{ formatBytes(uploadedBytes) }} / {{ formatBytes(totalBytes) }}
            </span>
            <span v-if="uploadSpeed > 0 && uploadProgress < 100" class="speed-text">
              · {{ formatBytes(uploadSpeed) }}/s
            </span>
            <span v-if="uploadProgress >= 100" class="stage-processing">· 正在处理视频...</span>
          </div>
        </div>
      </el-form>
      <div slot="footer">
        <el-button @click="uploadVisible = false" :disabled="uploading">取消</el-button>
        <el-button type="primary" :loading="uploading" @click="handleUpload">
          {{ uploading ? '上传中...' : '确定上传' }}
        </el-button>
      </div>
    </el-dialog>

    <!-- 编辑对话框 -->
    <el-dialog title="编辑视频" :visible.sync="editVisible" width="500px">
      <el-form :model="editForm" label-width="80px">
        <el-form-item label="标题">
          <el-input v-model="editForm.title"></el-input>
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="editForm.description" type="textarea" :rows="3"></el-input>
        </el-form-item>
        <el-form-item label="分类">
          <el-select v-model="editForm.category" style="width: 100%">
            <el-option label="科普视频" value="科普视频"></el-option>
            <el-option label="记录片段" value="记录片段"></el-option>
          </el-select>
        </el-form-item>
      </el-form>
      <div slot="footer">
        <el-button @click="editVisible = false">取消</el-button>
        <el-button type="primary" @click="handleEdit">确定</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import http from '@/utils/auth.js';
import AppNavbar from '@/components/Navbar.vue';

export default {
  name: 'VideoAdmin',
  components: { AppNavbar },
  data() {
    return {
      videos: [],
      loading: false,
      currentPage: 1,
      pageSize: 10,
      total: 0,
      searchTitle: '',
      searchCategory: '',
      uploadVisible: false,
      uploading: false,
      uploadForm: { title: '', description: '', category: '科普视频' },
      selectedFile: null,
      // 上传进度相关
      uploadProgress: 0,
      uploadStage: '准备上传...',
      uploadedBytes: 0,
      totalBytes: 0,
      uploadSpeed: 0,
      uploadStartTime: 0,
      lastProgressTime: 0,
      lastLoadedBytes: 0,
      uploadError: false,
      editVisible: false,
      editForm: { id: null, title: '', description: '', category: '' }
    };
  },
  mounted() {
    this.fetchList();
  },
  computed: {
    uploadProgressStatus() {
      if (this.uploadError) return 'exception';
      if (this.uploadProgress >= 100) return 'success';
      return undefined;
    }
  },
  methods: {
    async fetchList() {
      this.loading = true;
      try {
        const res = await http.get('/api/admin/videos', {
          params: {
            page: this.currentPage,
            size: this.pageSize,
            title: this.searchTitle || undefined,
            category: this.searchCategory || undefined
          }
        });
        if (res.data.code === 200) {
          this.videos = res.data.data.records || [];
          this.total = res.data.data.total || 0;
        }
      } catch (e) {
        if (e.response && e.response.status === 403) {
          this.$message.error('无权限访问');
          this.$router.push('/index');
        } else {
          this.$message.error('获取列表失败');
        }
      } finally {
        this.loading = false;
      }
    },
    showUploadDialog() {
      this.uploadForm = { title: '', description: '', category: '科普视频' };
      this.selectedFile = null;
      this.resetProgress();
      this.uploadVisible = true;
      this.$nextTick(() => {
        if (this.$refs.uploadRef) this.$refs.uploadRef.clearFiles();
      });
    },
    resetProgress() {
      this.uploadProgress = 0;
      this.uploadStage = '准备上传...';
      this.uploadedBytes = 0;
      this.totalBytes = 0;
      this.uploadSpeed = 0;
      this.uploadStartTime = 0;
      this.lastProgressTime = 0;
      this.lastLoadedBytes = 0;
      this.uploadError = false;
    },
    formatBytes(bytes) {
      if (!bytes || bytes < 0) return '0 B';
      const units = ['B', 'KB', 'MB', 'GB'];
      let i = 0;
      let val = bytes;
      while (val >= 1024 && i < units.length - 1) { val /= 1024; i++; }
      return val.toFixed(i === 0 ? 0 : 2) + ' ' + units[i];
    },
    handleFileChange(file) {
      this.selectedFile = file.raw;
      // 如果标题为空，用文件名填充
      if (!this.uploadForm.title && file.name) {
        this.uploadForm.title = file.name.replace(/\.[^.]+$/, '');
      }
    },
    handleExceed() {
      this.$message.warning('只能上传一个视频文件');
    },
    async handleUpload() {
      if (!this.uploadForm.title) { this.$message.warning('请输入标题'); return; }
      if (!this.selectedFile) { this.$message.warning('请选择视频文件'); return; }
      this.uploading = true;
      this.resetProgress();
      this.uploadStage = '上传中...';
      this.totalBytes = this.selectedFile.size;
      this.uploadStartTime = Date.now();
      this.lastProgressTime = Date.now();
      this.lastLoadedBytes = 0;
      try {
        const formData = new FormData();
        formData.append('file', this.selectedFile);
        formData.append('title', this.uploadForm.title);
        formData.append('description', this.uploadForm.description || '');
        formData.append('category', this.uploadForm.category);
        const res = await http.post('/api/admin/videos', formData, {
          headers: { 'Content-Type': 'multipart/form-data' },
          timeout: 300000,
          onUploadProgress: (progressEvent) => {
            this.handleUploadProgress(progressEvent);
          }
        });
        if (res.data.code === 200) {
          this.uploadProgress = 100;
          this.uploadStage = '上传完成';
          this.$message.success('上传成功，视频正在后台转码生成封面...');
          this.uploadVisible = false;
          this.fetchList();
        } else {
          this.uploadError = true;
          this.uploadStage = '上传失败';
          this.$message.error(res.data.message || '上传失败');
        }
      } catch (e) {
        this.uploadError = true;
        this.uploadStage = '上传失败';
        this.$message.error('上传失败: ' + (e.response?.data?.message || e.message));
      } finally {
        this.uploading = false;
      }
    },
    handleUploadProgress(progressEvent) {
      if (!progressEvent.total) return;
      this.uploadedBytes = progressEvent.loaded;
      const percent = Math.round((progressEvent.loaded * 100) / progressEvent.total);
      // 平滑显示，最多到 99%（100% 留给后端处理完成）
      this.uploadProgress = Math.min(percent, 99);
      // 计算实时上传速度（按最近一段时间窗口）
      const now = Date.now();
      const dt = (now - this.lastProgressTime) / 1000;
      if (dt >= 0.5) { // 每 0.5s 更新一次速度
        const dBytes = progressEvent.loaded - this.lastLoadedBytes;
        if (dBytes > 0 && dt > 0) {
          this.uploadSpeed = Math.round(dBytes / dt);
        }
        this.lastProgressTime = now;
        this.lastLoadedBytes = progressEvent.loaded;
      }
      // 阶段提示
      if (percent >= 100) {
        this.uploadStage = '文件已上传，等待服务器处理...';
      } else if (percent >= 80) {
        this.uploadStage = '上传中... 即将完成';
      } else if (percent >= 40) {
        this.uploadStage = '上传中...';
      }
    },
    showEditDialog(row) {
      this.editForm = { id: row.id, title: row.title, description: row.description || '', category: row.category };
      this.editVisible = true;
    },
    async handleEdit() {
      try {
        const res = await http.put(`/api/admin/videos/${this.editForm.id}`, {
          title: this.editForm.title,
          description: this.editForm.description,
          category: this.editForm.category
        });
        if (res.data.code === 200) {
          this.$message.success('更新成功');
          this.editVisible = false;
          this.fetchList();
        } else {
          this.$message.error(res.data.message || '更新失败');
        }
      } catch (e) {
        this.$message.error('更新失败');
      }
    },
    handleDelete(row) {
      this.$confirm(`确定删除视频「${row.title}」吗？此操作不可恢复。`, '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(async () => {
        try {
          const res = await http.delete(`/api/admin/videos/${row.id}`);
          if (res.data.code === 200) {
            this.$message.success('删除成功');
            this.fetchList();
          } else {
            this.$message.error(res.data.message || '删除失败');
          }
        } catch (e) {
          this.$message.error('删除失败');
        }
      }).catch(() => {});
    },
    formatDuration(seconds) {
      if (!seconds) return '-';
      const m = Math.floor(seconds / 60);
      const s = Math.floor(seconds % 60);
      return `${m}:${s < 10 ? '0' : ''}${s}`;
    }
  }
};
</script>

<style scoped>
.video-admin-page {
  min-height: 100vh;
  background: url('/images/780.jpg') center/cover no-repeat fixed;
}
.center-body { max-width: 1200px; margin: 0 auto; padding: 2vh 2vw; }
.admin-container {
  background-color: rgba(255,255,255,0.92);
  border-radius: 12px;
  padding: 2vh 2vw;
  box-shadow: 0 4px 20px rgba(0,0,0,0.15);
}
.admin-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5vh; }
.admin-title { color: #1e3c72; margin: 0; font-size: 2.2vh; }
.search-bar { margin-bottom: 1.5vh; }
.pagination-wrap { margin-top: 2vh; text-align: center; }

/* 上传进度条样式 */
.upload-progress-wrap {
  background: #f5f7fa;
  border-radius: 8px;
  padding: 12px 14px;
  margin-top: 10px;
  border: 1px solid #e4e7ed;
}
.progress-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}
.progress-stage {
  font-size: 13px;
  color: #303133;
  font-weight: 500;
}
.progress-percent {
  font-size: 13px;
  color: #409eff;
  font-weight: 600;
}
.progress-detail {
  margin-top: 6px;
  font-size: 12px;
  color: #909399;
  display: flex;
  align-items: center;
  gap: 4px;
}
.progress-detail .speed-text { color: #67c23a; }
.progress-detail .stage-processing { color: #e6a23c; }

</style>
