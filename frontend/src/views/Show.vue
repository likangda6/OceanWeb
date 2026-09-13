<template>
  <div class="show-page">
    <app-navbar :active="'show'" />
    <div id="container">
      <div class="legend">
        <div class="legend-item" data-depth="0"><span class="legend-color" style="background-color: #1f77b4;"></span>根节点</div>
        <div class="legend-item" data-depth="1"><span class="legend-color" style="background-color: #ff7f0e;"></span>纲</div>
        <div class="legend-item" data-depth="2"><span class="legend-color" style="background-color: #2ca02c;"></span>目</div>
        <div class="legend-item" data-depth="3"><span class="legend-color" style="background-color: #d62728;"></span>科</div>
        <div class="legend-item" data-depth="4"><span class="legend-color" style="background-color: #8c564b;"></span>种</div>
      </div>

      <div class="filter-panel">
        <div class="filter-title">分类筛选:</div>
        <div class="filter-options" id="class-filters">
          <div class="filter-option active" data-class="all">全部</div>
        </div>
      </div>

      <div class="box">
        <div class="search-container">
          <input type="text" id="search" placeholder="请搜索分类或物种...">
        </div>
        <div class="controls">
          <button id="showAll">显示全部</button>
          <button id="showSpecies">仅显示物种</button>
          <button id="showHigher">仅显示高级分类</button>
        </div>
      </div>

      <div id="graph-container">
        <div id="graph">
          <div class="loading">加载海洋物种网络中...</div>
        </div>
        <div id="info-panel">
          <h2>欢迎使用海洋物种分类网络</h2>
          <img src="/images/species/sea3.png" alt="海洋生物">
          <p>这是一个交互式的海洋物种分类网络图谱，展示了海洋生物的分类关系。</p>
          <p><strong>使用方法：</strong></p>
          <ul>
            <li>点击节点查看详细信息</li>
            <li>右键点击节点显示上下文菜单（移动端暂不支持）</li>
            <li>拖动节点可以重新布局网络</li>
            <li>使用鼠标滚轮或双指缩放视图</li>
            <li>使用搜索框快速定位分类或物种</li>
            <li>使用筛选器按分类级别查看</li>
            <li>点击图例可以显示/隐藏特定分类级别</li>
            <li>点击高级分类节点展开/折叠子节点</li>
          </ul>
          <p>数据来源：综合各类海洋生物学分类资料</p>
        </div>
      </div>
    </div>

    <div class="tooltip"></div>
  </div>
</template>

<script>
import AppNavbar from '@/components/Navbar.vue';

export default {
  name: 'Show',
  components: { AppNavbar },
  data() {
    return {
      show: 'show'
    };
  },
  mounted() {
    // d3 相关非响应式属性
    this.width = 1000;
    this.height = 750;
    this.graphData = { nodes: [], links: [], nodeMap: {} };
    this.simulation = null;
    this.link = null;
    this.node = null;
    this.svg = null;
    this.svgGroup = null;
    this.color = null;
    this.radiusScale = null;
    this.loadD3();
  },
  methods: {
    /* ==================== d3 动态加载 ==================== */
    loadD3() {
      if (window.d3) {
        this.initTaxonomyGraph();
        return;
      }
      var self = this;
      var script = document.createElement('script');
      script.src = 'https://d3js.org/d3.v7.min.js';
      script.onload = function () { self.initTaxonomyGraph(); };
      script.onerror = function () {
        var loading = document.querySelector('.loading');
        if (loading) loading.textContent = '加载失败，请刷新重试';
      };
      document.head.appendChild(script);
    },

    /* ==================== 后端 API 调用 ==================== */
    async fetchTaxonomyData() {
      try {
        var response = await fetch('/api/species/taxonomy-tree');
        if (!response.ok) throw new Error('Network response was not ok');
        return await response.json();
      } catch (error) {
        console.error('Error fetching taxonomy data:', error);
        return {};
      }
    },

    async fetchFamilySpecies(familyName) {
      try {
        var response = await fetch('/api/species/family/' + encodeURIComponent(familyName));
        if (!response.ok) throw new Error('Network response was not ok');
        return await response.json();
      } catch (error) {
        console.error('Error fetching species for family ' + familyName + ':', error);
        return [];
      }
    },

    async fetchSpeciesDetail(id) {
      try {
        var response = await fetch('/api/species/' + id);
        if (!response.ok) throw new Error('Network response was not ok');
        return await response.json();
      } catch (error) {
        console.error('Error fetching species detail:', error);
        return null;
      }
    },

    /* ==================== 数据转换 ==================== */
    convertApiDataToForceGraph(apiData) {
      var nodes = [];
      var links = [];
      var nodeMap = {};
      var nodeId = 0;

      var rootNode = {
        id: nodeId++,
        name: "海洋生物",
        depth: 0,
        type: "root",
        children: []
      };
      nodes.push(rootNode);
      nodeMap["root"] = rootNode;

      var classes = Object.keys(apiData);
      for (var ci = 0; ci < classes.length; ci++) {
        var className = classes[ci];
        var orders = apiData[className];
        var classNode = {
          id: nodeId++,
          name: className,
          depth: 1,
          type: "class",
          class: className,
          parent: rootNode,
          children: []
        };
        nodes.push(classNode);
        nodeMap['class_' + className] = classNode;
        links.push({ source: rootNode.id, target: classNode.id, value: 2 });
        rootNode.children.push(classNode);

        var orderNames = Object.keys(orders);
        for (var oi = 0; oi < orderNames.length; oi++) {
          var orderName = orderNames[oi];
          var families = orders[orderName];
          var orderNode = {
            id: nodeId++,
            name: orderName,
            depth: 2,
            type: "order",
            class: className,
            order: orderName,
            parent: classNode,
            children: []
          };
          nodes.push(orderNode);
          nodeMap['order_' + orderName] = orderNode;
          links.push({ source: classNode.id, target: orderNode.id, value: 2 });
          classNode.children.push(orderNode);

          var familyNames = Object.keys(families);
          for (var fi = 0; fi < familyNames.length; fi++) {
            var familyName = familyNames[fi];
            var speciesList = families[familyName];
            var familyNode = {
              id: nodeId++,
              name: familyName,
              depth: 3,
              type: "family",
              class: className,
              order: orderName,
              family: familyName,
              parent: orderNode,
              children: [],
              speciesCount: Array.isArray(speciesList) ? speciesList.length : 0
            };
            nodes.push(familyNode);
            nodeMap['family_' + familyName] = familyNode;
            links.push({ source: orderNode.id, target: familyNode.id, value: 2 });
            orderNode.children.push(familyNode);
            familyNode.childrenLoaded = false;
          }
        }
      }

      return { nodes: nodes, links: links, nodeMap: nodeMap };
    },

    /* ==================== 物种节点加载 ==================== */
    async addSpeciesNodes(familyNode) {
      if (familyNode.childrenLoaded) return;
      var self = this;
      var speciesList = await this.fetchFamilySpecies(familyNode.name);
      var newNodes = [];
      var newLinks = [];

      for (var i = 0; i < speciesList.length; i++) {
        var species = speciesList[i];
        if (species && species.name) {
          var speciesNode = {
            id: self.graphData.nodes.length + newNodes.length,
            name: species.name,
            depth: 4,
            type: "species",
            class: familyNode.class,
            order: familyNode.order,
            family: familyNode.name,
            info: species.description || "",
            image: species.image_url || "",
            speciesId: species.id,
            parent: familyNode
          };
          newNodes.push(speciesNode);
          self.graphData.nodeMap['species_' + species.id] = speciesNode;
          newLinks.push({
            source: familyNode.id,
            target: speciesNode.id,
            value: 1,
            id: Math.min(familyNode.id, speciesNode.id) + '-' + Math.max(familyNode.id, speciesNode.id)
          });
          familyNode.children.push(speciesNode);
        }
      }

      self.graphData.nodes = self.graphData.nodes.concat(newNodes);
      self.graphData.links = self.graphData.links.concat(newLinks);
      familyNode.childrenLoaded = true;
      self.updateSimulation();
      return { newNodes: newNodes, newLinks: newLinks };
    },

    /* ==================== 仿真与视觉更新 ==================== */
    updateSimulation() {
      if (!this.simulation) return;
      this.simulation.nodes(this.graphData.nodes);
      this.simulation.force("link").links(this.graphData.links);
      this.simulation.alpha(0.5).restart();
      this.updateVisualElements();
    },

    updateVisualElements() {
      var self = this;
      self.link = self.link.data(self.graphData.links, function (d) {
        return Math.min(d.source.id, d.target.id) + '-' + Math.max(d.source.id, d.target.id);
      });
      self.link.exit().remove();
      self.link = self.link.enter().append("line")
        .attr("class", "link")
        .attr("id", function (d) { return 'link-' + Math.min(d.source.id, d.target.id) + '-' + Math.max(d.source.id, d.target.id); })
        .attr("stroke", function (d) { return self.color(d.source.depth); })
        .attr("stroke-width", 1)
        .merge(self.link);

      var nodeGroups = self.node.data(self.graphData.nodes, function (d) { return d.id; });
      nodeGroups.exit().remove();

      var newNodeGroups = nodeGroups.enter().append("g")
        .attr("class", function (d) { return 'node depth-' + d.depth; })
        .attr("id", function (d) { return 'node-' + d.id; })
        .call(d3.drag()
          .on("start", function (event, d) { self.dragstarted(event, d); })
          .on("drag", function (event, d) { self.dragged(event, d); })
          .on("end", function (event, d) { self.dragended(event, d); }));

      newNodeGroups.append("circle")
        .attr("r", function (d) { return self.radiusScale(5 - d.depth); })
        .attr("fill", function (d) { return self.color(d.depth); })
        .attr("stroke", function (d) { return d3.color(self.color(d.depth)).darker(0.5); })
        .attr("stroke-width", function (d) { return d.depth < 3 ? 2 : 1; })
        .classed("expandable", function (d) { return d.depth < 4; })
        .classed("collapsed", function (d) { return d.depth < 4 && !d.childrenVisible; })
        .classed("expanded", function (d) { return d.depth < 4 && d.childrenVisible; });

      newNodeGroups.append("text")
        .attr("dy", 4)
        .attr("text-anchor", "middle")
        .text(function (d) {
          if (d.depth === 3 && d.speciesCount > 0 && !d.childrenLoaded) {
            return d.name + ' (' + d.speciesCount + '种)';
          }
          return d.name;
        })
        .attr("class", function (d) { return 'depth-' + d.depth; })
        .style("display", "block");

      self.node = newNodeGroups.merge(nodeGroups);
      self.bindNodeEvents();
    },

    /* ==================== 节点事件绑定 ==================== */
    bindNodeEvents() {
      var self = this;
      var tooltip = d3.select(".tooltip");

      self.node.on("click", async function (event, d) {
        event.stopPropagation();
        if (d.depth < 4) {
          if (d.childrenVisible) {
            self.collapseNode(d);
          } else {
            await self.expandNode(d);
          }
          d.childrenVisible = !d.childrenVisible;
          d3.select(this).select("circle")
            .classed("collapsed", !d.childrenVisible)
            .classed("expanded", d.childrenVisible);
          if (d.depth === 3 && d.childrenVisible) {
            d3.select(this).select("text").text(d.name);
          }
        }
        self.highlightNode(d);
        self.updateNodeInfo(d);
      });

      self.node.on("mouseover", function (event, d) {
        tooltip.transition().duration(200).style("opacity", 0.9);
        tooltip.html(d.name + '<br><small>' + self.getTypeName(d.type) + '</small>')
          .style("left", (event.pageX + 10) + "px")
          .style("top", (event.pageY - 28) + "px");
        self.node.select("circle").style("opacity", 0.2);
        self.node.select("text").style("opacity", 0.2);
        d3.select(this).select("circle").style("opacity", 1);
        d3.select(this).select("text").style("opacity", 1);
        var connectedNodeIds = {};
        self.graphData.links.forEach(function (l) {
          if (l.source.id === d.id) { connectedNodeIds[l.target.id] = true; }
          if (l.target.id === d.id) { connectedNodeIds[l.source.id] = true; }
        });
        self.node.filter(function (n) { return connectedNodeIds[n.id]; }).select("circle").style("opacity", 0.8);
        self.node.filter(function (n) { return connectedNodeIds[n.id]; }).select("text").style("opacity", 0.8);
      });

      self.node.on("mouseout", function () {
        tooltip.transition().duration(500).style("opacity", 0);
        self.node.select("circle").style("opacity", 1);
        self.node.select("text").style("opacity", 1);
      });

      self.node.on("contextmenu", function (event, d) {
        event.preventDefault();
        var menu = d3.select("#context-menu");
        if (menu.empty()) {
          menu = d3.select("body").append("div").attr("id", "context-menu");
        }
        menu.html("")
          .style("left", event.pageX + "px")
          .style("top", event.pageY + "px")
          .style("display", "block");
        if (d.depth < 4) {
          menu.append("div").text(d.childrenVisible ? "折叠子节点" : "展开子节点")
            .on("click", function () {
              if (d.childrenVisible) { self.collapseNode(d); } else { self.expandNode(d); }
              d.childrenVisible = !d.childrenVisible;
              menu.style("display", "none");
            });
        }
        menu.append("div").text("聚焦此节点").on("click", function () { self.focusOnNode(d); menu.style("display", "none"); });
        menu.append("div").text("隐藏此节点").on("click", function () { self.hideNode(d); menu.style("display", "none"); });
        d3.select("body").on("click.context-menu", function () { menu.style("display", "none"); }, true);
      });
    },

    /* ==================== 节点展开/折叠 ==================== */
    async expandNode(nodeData) {
      var self = this;
      if (nodeData.depth === 3 && !nodeData.childrenLoaded) await self.addSpeciesNodes(nodeData);
      var childNodes = nodeData.children || [];
      childNodes.forEach(function (child) {
        d3.select('#node-' + child.id).style("display", "block");
        var linkId = 'link-' + Math.min(nodeData.id, child.id) + '-' + Math.max(nodeData.id, child.id);
        d3.select('#' + linkId).style("display", "block");
      });
      self.simulation.alpha(0.5).restart();
    },

    collapseNode(nodeData) {
      var self = this;
      var allDescendants = self.getAllDescendants(nodeData);
      allDescendants.forEach(function (desc) {
        d3.select('#node-' + desc.id).style("display", "none");
        if (desc.parent) {
          var linkId = 'link-' + Math.min(desc.parent.id, desc.id) + '-' + Math.max(desc.parent.id, desc.id);
          d3.select('#' + linkId).style("display", "none");
        }
      });
      self.simulation.alpha(0.5).restart();
    },

    getAllDescendants(nodeData) {
      var self = this;
      var descendants = [];
      if (nodeData.children) {
        nodeData.children.forEach(function (child) {
          descendants.push(child);
          descendants = descendants.concat(self.getAllDescendants(child));
        });
      }
      return descendants;
    },

    /* ==================== 高亮/聚焦/隐藏 ==================== */
    highlightNode(nodeData) {
      var self = this;
      d3.selectAll(".node circle").classed("highlight", false);
      d3.selectAll(".node text").classed("highlight-text", false);
      d3.selectAll(".link").classed("highlight-link", false);
      d3.select('#node-' + nodeData.id).select("circle").classed("highlight", true);
      d3.select('#node-' + nodeData.id).select("text").classed("highlight-text", true);
      var connectedLinks = self.graphData.links.filter(function (l) {
        return l.source.id === nodeData.id || l.target.id === nodeData.id;
      });
      self.link.classed("highlight-link", function (l) { return connectedLinks.indexOf(l) !== -1; });
    },

    focusOnNode(nodeData) {
      var self = this;
      var descendants = [nodeData].concat(self.getAllDescendants(nodeData));
      var xExtent = d3.extent(descendants, function (d) { return d.x; });
      var yExtent = d3.extent(descendants, function (d) { return d.y; });
      var padding = 50;
      var targetWidth = xExtent[1] - xExtent[0] + padding * 2;
      var targetHeight = yExtent[1] - yExtent[0] + padding * 2;
      var scale = Math.min(self.width / targetWidth, self.height / targetHeight) * 0.9;
      var centerX = (xExtent[0] + xExtent[1]) / 2;
      var centerY = (yExtent[0] + yExtent[1]) / 2;
      self.svg.transition().duration(1000).call(
        self.svg.node().__zoom.transform,
        d3.zoomIdentity.translate(self.width / 2, self.height / 2).scale(scale).translate(-centerX, -centerY)
      );
    },

    hideNode(nodeData) {
      var self = this;
      var nodesToHide = [nodeData].concat(self.getAllDescendants(nodeData));
      nodesToHide.forEach(function (n) {
        d3.select('#node-' + n.id).style("display", "none");
      });
      self.graphData.links.forEach(function (lnk) {
        if (nodesToHide.some(function (n) { return n.id === lnk.source.id || n.id === lnk.target.id; })) {
          d3.select('#link-' + lnk.source.id + '-' + lnk.target.id).style("display", "none");
        }
      });
    },

    /* ==================== 信息面板更新 ==================== */
    async updateNodeInfo(nodeData) {
      var self = this;
      if (nodeData.speciesId) {
        var speciesDetail = await self.fetchSpeciesDetail(nodeData.speciesId);
        if (speciesDetail) {
          self.updateInfoPanel({
            name: speciesDetail.name,
            info: '<strong>纲:</strong> ' + nodeData.class + '<br><strong>目:</strong> ' + nodeData.order + '<br><strong>科:</strong> ' + nodeData.family + '<br><strong>描述:</strong> ' + (speciesDetail.description || '暂无描述'),
            image: speciesDetail.imageUrl
          });
        }
      } else {
        var info = '<strong>分类级别:</strong> ' + self.getTypeName(nodeData.type) + '<br>';
        if (nodeData.class) info += '<strong>纲:</strong> ' + nodeData.class + '<br>';
        if (nodeData.order) info += '<strong>目:</strong> ' + nodeData.order + '<br>';
        if (nodeData.family) info += '<strong>科:</strong> ' + nodeData.family + '<br>';
        if (nodeData.children && nodeData.children.length > 0) info += '<strong>包含子类:</strong> ' + nodeData.children.length + '个<br>';
        self.updateInfoPanel({
          name: nodeData.name,
          info: info,
          image: null
        });
      }
    },

    updateInfoPanel(data) {
      var infoPanel = d3.select("#info-panel");
      infoPanel.transition().duration(300).style("opacity", 0).on("end", function () {
        var imageHtml = '';
        if (data.image) {
          imageHtml = '<img src="' + data.image + '" alt="' + data.name + '" onerror="this.src=\'https://images.unsplash.com/photo-1534766555767-14c979e39a4a?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80\'">';
        }
        infoPanel.html('<h2>' + data.name + '</h2>' + imageHtml + '<div>' + (data.info || "这是分类节点，请点击具体物种查看详细信息。") + '</div>').style("opacity", 1);
      });
    },

    getTypeName(type) {
      var typeNames = { root: "根节点", class: "纲", order: "目", family: "科", species: "物种" };
      return typeNames[type] || type;
    },

    /* ==================== 拖拽处理 ==================== */
    dragstarted(event, d) {
      if (!event.active) this.simulation.alphaTarget(0.3).restart();
      d.fx = d.x;
      d.fy = d.y;
    },

    dragged(event, d) {
      d.fx = event.x;
      d.fy = event.y;
    },

    dragended(event, d) {
      if (!event.active) this.simulation.alphaTarget(0);
      d.fx = null;
      d.fy = null;
    },

    /* ==================== 控件事件绑定 ==================== */
    bindControlEvents() {
      var self = this;

      d3.select("#search").on("input", async function () {
        var searchTerm = this.value.toLowerCase().trim();
        self.node.select("circle").classed("highlight", false);
        self.node.select("text").classed("highlight-text", false);
        if (searchTerm.length < 2) {
          self.node.style("display", "block");
          self.link.style("display", "block");
          return;
        }
        var matches = self.graphData.nodes.filter(function (d) { return d.name.toLowerCase().indexOf(searchTerm) !== -1; });
        var familyMatches = matches.filter(function (d) { return d.depth === 3 && !d.childrenLoaded; });
        for (var i = 0; i < familyMatches.length; i++) {
          var familyNode = familyMatches[i];
          await self.addSpeciesNodes(familyNode);
          familyNode.childrenVisible = true;
        }
        var allMatches = self.graphData.nodes.filter(function (d) { return d.name.toLowerCase().indexOf(searchTerm) !== -1; });
        if (allMatches.length > 0) {
          self.node.style("display", "none");
          self.link.style("display", "none");
          allMatches.forEach(function (match) {
            d3.select('#node-' + match.id).style("display", "block");
            var current = match;
            while (current && current.parent) {
              d3.select('#node-' + current.parent.id).style("display", "block");
              var linkId = 'link-' + Math.min(current.parent.id, current.id) + '-' + Math.max(current.parent.id, current.id);
              d3.select('#' + linkId).style("display", "block");
              current = current.parent;
            }
            if (match.childrenVisible && match.children) {
              match.children.forEach(function (child) { d3.select('#node-' + child.id).style("display", "block"); });
            }
            d3.select('#node-' + match.id).select("circle").classed("highlight", true);
            d3.select('#node-' + match.id).select("text").classed("highlight-text", true);
          });
        } else {
          self.node.style("display", "block");
          self.link.style("display", "block");
        }
      });

      d3.select("#showAll").on("click", function () {
        self.node.select("text").style("display", "block");
        d3.select(this).classed("active", true);
        d3.select("#showSpecies").classed("active", false);
        d3.select("#showHigher").classed("active", false);
      });

      d3.select("#showSpecies").on("click", function () {
        self.node.select("text").style("display", function (d) { return d.depth === 4 ? "block" : "none"; });
        d3.select(this).classed("active", true);
        d3.select("#showAll").classed("active", false);
        d3.select("#showHigher").classed("active", false);
      });

      d3.select("#showHigher").on("click", function () {
        self.node.select("text").style("display", function (d) { return d.depth < 4 ? "block" : "none"; });
        d3.select(this).classed("active", true);
        d3.select("#showAll").classed("active", false);
        d3.select("#showSpecies").classed("active", false);
      });

      d3.selectAll(".legend-item").on("click", function () {
        var depth = +this.dataset.depth;
        var isActive = d3.select(this).classed("active");
        d3.select(this).classed("active", !isActive);
        self.node.filter(function (d) { return d.depth === depth; }).style("display", isActive ? "block" : "none");
        self.link.style("display", function (l) {
          var sourceVisible = self.node.filter(function (n) { return n.id === l.source.id; }).style("display") !== "none";
          var targetVisible = self.node.filter(function (n) { return n.id === l.target.id; }).style("display") !== "none";
          return sourceVisible && targetVisible ? "block" : "none";
        });
      });
    },

    /* ==================== 图谱初始化 ==================== */
    async initTaxonomyGraph() {
      var self = this;
      try {
        // 初始化颜色比例尺
        self.color = d3.scaleOrdinal()
          .domain([0, 1, 2, 3, 4])
          .range(["#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#8c564b"]);

        self.radiusScale = d3.scaleSqrt()
          .domain([0, 4])
          .range([13, 22]);

        d3.select(".loading").remove();
        self.svg = d3.select("#graph")
          .append("svg")
          .attr("viewBox", "0 0 1000 750")
          .attr("preserveAspectRatio", "xMidYMid meet")
          .call(d3.zoom().scaleExtent([0.1, 5]).on("zoom", function (event) { self.svgGroup.attr("transform", event.transform); }))
          .append("g");
        self.svgGroup = self.svg.append("g");

        var apiData = await self.fetchTaxonomyData();
        self.graphData = self.convertApiDataToForceGraph(apiData);

        self.simulation = d3.forceSimulation(self.graphData.nodes)
          .force("link", d3.forceLink(self.graphData.links).id(function (d) { return d.id; }).distance(function (d) { return d.value * 30; }))
          .force("charge", d3.forceManyBody().strength(-200))
          .force("center", d3.forceCenter(self.width / 2, self.height / 2))
          .force("x", d3.forceX(self.width / 2).strength(0.05))
          .force("y", d3.forceY(self.height / 2).strength(0.05))
          .force("collision", d3.forceCollide().radius(function (d) { return self.radiusScale(5 - d.depth) + 2; }))
          .alphaDecay(0.05).velocityDecay(0.4);

        self.link = self.svgGroup.append("g").selectAll("line").data(self.graphData.links).enter().append("line")
          .attr("class", "link").attr("id", function (d) { return 'link-' + d.source.id + '-' + d.target.id; })
          .attr("stroke", function (d) { return self.color(d.source.depth); }).attr("stroke-width", 1);

        self.node = self.svgGroup.append("g").selectAll("g").data(self.graphData.nodes, function (d) { return d.id; }).enter().append("g")
          .attr("class", function (d) { return 'node depth-' + d.depth; }).attr("id", function (d) { return 'node-' + d.id; })
          .call(d3.drag()
            .on("start", function (event, d) { self.dragstarted(event, d); })
            .on("drag", function (event, d) { self.dragged(event, d); })
            .on("end", function (event, d) { self.dragended(event, d); }));

        self.node.append("circle").attr("r", function (d) { return self.radiusScale(5 - d.depth); }).attr("fill", function (d) { return self.color(d.depth); })
          .attr("stroke", function (d) { return d3.color(self.color(d.depth)).darker(0.5); }).attr("stroke-width", function (d) { return d.depth < 3 ? 2 : 1; })
          .classed("expandable", function (d) { return d.depth < 4; }).classed("collapsed", function (d) { return d.depth < 4; });

        self.node.append("text").attr("dy", 4).attr("text-anchor", "middle")
          .text(function (d) { return d.depth === 3 && d.speciesCount > 0 ? d.name + ' (' + d.speciesCount + '种)' : d.name; })
          .attr("class", function (d) { return 'depth-' + d.depth; }).style("display", "block");

        self.bindNodeEvents();

        // 分类筛选器
        var classes = Object.keys(apiData);
        var classFilters = d3.select("#class-filters");
        classFilters.select(".filter-option[data-class='all']").on("click", function () {
          d3.selectAll(".filter-option").classed("active", false);
          d3.select(this).classed("active", true);
          self.node.style("display", "block");
          self.link.style("display", "block");
          self.svg.transition().duration(750).call(self.svg.node().__zoom.transform, d3.zoomIdentity);
        });

        classes.forEach(function (className) {
          classFilters.append("div").attr("class", "filter-option").attr("data-class", className).text(className)
            .on("click", function () {
              var isActive = d3.select(this).classed("active");
              d3.select(this).classed("active", !isActive);
              d3.select(".filter-option[data-class='all']").classed("active", false);
              var activeClasses = [];
              d3.selectAll(".filter-option.active").each(function () {
                var cls = d3.select(this).attr("data-class");
                if (cls !== "all") activeClasses.push(cls);
              });
              if (activeClasses.length === 0) {
                self.node.style("display", "block");
                self.link.style("display", "block");
                d3.select(".filter-option[data-class='all']").classed("active", true);
              } else {
                self.node.style("display", function (d) { return activeClasses.indexOf(d.class) !== -1 || d.depth < 1 ? "block" : "none"; });
                self.link.style("display", function (l) {
                  var src = self.graphData.nodes.find(function (n) { return n.id === l.source.id; });
                  var tgt = self.graphData.nodes.find(function (n) { return n.id === l.target.id; });
                  return (activeClasses.indexOf(src.class) !== -1 || src.depth < 1) && (activeClasses.indexOf(tgt.class) !== -1 || tgt.depth < 1) ? "block" : "none";
                });
              }
            });
        });

        self.bindControlEvents();

        self.simulation.on("tick", function () {
          self.link.attr("x1", function (d) { return d.source.x; }).attr("y1", function (d) { return d.source.y; })
            .attr("x2", function (d) { return d.target.x; }).attr("y2", function (d) { return d.target.y; });
          self.node.attr("transform", function (d) { return 'translate(' + d.x + ',' + d.y + ')'; });
        });

        // 默认展开根节点
        var rootNode = self.graphData.nodeMap["root"];
        rootNode.childrenVisible = true;
        d3.select('#node-' + rootNode.id).select("circle").classed("expanded", true).classed("collapsed", false);
        rootNode.children.forEach(function (child) {
          d3.select('#node-' + child.id).style("display", "block");
          d3.select('#link-' + rootNode.id + '-' + child.id).style("display", "block");
        });
      } catch (error) {
        console.error("初始化图谱失败:", error);
        var loadingEl = document.querySelector('.loading');
        if (loadingEl) loadingEl.textContent = '加载失败，请刷新重试';
      }
    }
  }
};
</script>

<style scoped>
/* ==================== 页面根容器（原 body 样式） ==================== */
.show-page {
  font-family: 'Arial', sans-serif;
  margin: 0;
  background-image: url('/images/780.jpg');
  background-size: cover;
  background-position: center center;
  background-repeat: no-repeat;
  color: #333;
  -webkit-tap-highlight-color: transparent;
  min-height: 100vh;
}

/* ==================== 原导航栏相关样式（已被 AppNavbar 组件替代，保留以防外部引用） ==================== */
.navbar {
  display: flex;
  overflow: hidden;
  background-color: rgba(255, 255, 255, 0.40);
  padding: 2vh 0;
  flex-shrink: 0;
  align-items: center;
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
  white-space: nowrap;
  transition: color 0.3s;
}

.dropbtn:hover, .dropdown:hover .dropbtn {
  color: yellow;
}

.changed {
  border-bottom: 0.5vh solid orange;
}

.navbar a:hover, .dropbtn {
  background-color: #ddd;
}

.dropdown:hover {
  display: block;
}

.right {
  position: absolute;
  right: 0;
  width: 15vw;
  height: 8vh;
  line-height: 8vh;
  color: white;
  display: flex;
  align-items: center;
}

.right img {
  width: 5vh;
  height: 5vh;
  margin: auto;
}

.library-name {
  margin-left: 3vw;
  display: flex;
  justify-content: center;
  align-items: center;
  flex-shrink: 0;
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

.left-nav {
  display: flex;
  align-items: center;
}

/* ==================== 主容器 ==================== */
#container {
  display: flex;
  flex-direction: column;
  align-items: center;
  max-width: 1400px;
  margin: 0 auto;
  width: 100%;
}

#graph-container {
  display: flex;
  width: 100%;
  gap: 20px;
  margin-bottom: 20px;
}

#graph {
  flex: 2;
  background-color: white;
  border-radius: 10px;
  box-shadow: 0 6px 12px rgba(0,0,0,0.15);
  height: 750px;
  position: relative;
  overflow: hidden;
  background-image: url("/images/111.jpg");
  background-size: cover;
  background-position: center center;
  background-repeat: no-repeat;
  border: 3px solid white;
}

#info-panel {
  flex: 1;
  background-color: white;
  border-radius: 10px;
  box-shadow: 0 6px 12px rgba(0,0,0,0.15);
  padding: 25px;
  height: 700px;
  overflow-y: auto;
  transition: all 0.3s ease;
}

.controls {
  margin: 20px 0;
  width: 100%;
  display: flex;
  justify-content: center;
  flex-wrap: wrap;
  gap: 10px;
}

button {
  padding: 8px 15px;
  background-color: #4a8bc9;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9em;
  transition: all 0.2s ease;
  box-shadow: 0 2px 5px rgba(0,0,0,0.1);
}

button:hover {
  background-color: #3a76b0;
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0,0,0,0.15);
}

button:active {
  transform: translateY(0);
}

button.active {
  background-color: #2a5d90;
  box-shadow: inset 0 2px 4px rgba(0,0,0,0.2);
}

.search-container {
  margin: 15px 0;
  width: 100%;
  display: flex;
  justify-content: center;
}

#search {
  padding: 10px 15px;
  width: 70%;
  border: 1px solid #ccc;
  border-radius: 6px;
  font-size: 1em;
  box-shadow: inset 0 1px 3px rgba(0,0,0,0.1);
}

.legend {
  display: flex;
  justify-content: center;
  flex-wrap: wrap;
  gap: 15px;
  margin: 15px 0;
}

.legend-item {
  display: flex;
  align-items: center;
  font-size: 0.9em;
  cursor: pointer;
}

.legend-color {
  width: 15px;
  height: 15px;
  border-radius: 50%;
  margin-right: 8px;
  border: 1px solid #ddd;
}

.tooltip {
  position: absolute;
  padding: 8px 12px;
  background: rgba(0, 0, 0, 0.8);
  color: white;
  border-radius: 4px;
  font-size: 12px;
  pointer-events: none;
  z-index: 10;
  opacity: 0;
  transition: opacity 0.3s;
}

.loading {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100%;
  font-size: 1.2em;
  color: #666;
}

.filter-panel {
  background-color: white;
  border-radius: 8px;
  padding: 15px;
  margin-bottom: 20px;
  box-shadow: 0 3px 6px rgba(0,0,0,0.1);
  width: 100%;
  box-sizing: border-box;
}

.filter-title {
  font-weight: bold;
  margin-bottom: 10px;
  color: #006994;
}

.filter-options {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.filter-option {
  padding: 5px 10px;
  background-color: #e6f2ff;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.85em;
  transition: all 0.2s;
}

.filter-option:hover {
  background-color: #cce0ff;
}

.filter-option.active {
  background-color: #4a8bc9;
  color: white;
}

.box {
  display: flex;
  width: 100%;
  justify-content: space-between;
  flex-wrap: wrap;
}

/* ==================== 移动端适配 ==================== */
@media (max-width: 768px) {
  .show-page {
    background-attachment: scroll;
  }

  .navbar {
    flex-wrap: nowrap;
    overflow-x: auto;
    overflow-y: hidden;
    -webkit-overflow-scrolling: touch;
    scrollbar-width: none;
    -ms-overflow-style: none;
    padding: 8px 5px;
    gap: 0;
  }

  .navbar::-webkit-scrollbar {
    display: none;
  }

  .library-name {
    margin-left: 8px;
    flex-shrink: 0;
  }

  .library-name img {
    width: 36px !important;
    height: 36px !important;
  }

  .library-title div:first-child {
    font-size: 18px !important;
  }

  .library-title div:last-child {
    font-size: 9px !important;
  }

  .left-nav {
    margin-left: 8px !important;
    display: flex;
    flex-wrap: nowrap;
    align-items: center;
    gap: 4px;
    flex-shrink: 0;
  }

  .dropdown .dropbtn {
    width: auto;
    min-width: 44px;
    height: auto;
    padding: 8px 6px;
    font-size: 13px;
    line-height: 1.2;
    border-radius: 6px;
  }

  .right {
    position: static;
    width: auto;
    height: auto;
    line-height: normal;
    flex-shrink: 0;
    margin-left: auto;
    padding-right: 5px;
    font-size: 11px;
    white-space: nowrap;
    display: flex;
    align-items: center;
    gap: 4px;
  }

  .right img {
    width: 24px;
    height: 24px;
    margin: 0;
  }

  #graph-container {
    flex-direction: column;
  }

  #graph {
    height: 50vh;
    min-height: 350px;
    width: 100%;
    border-radius: 0;
  }

  #info-panel {
    height: auto;
    max-height: 60vh;
    border-radius: 0;
  }

  .box {
    flex-direction: column;
    align-items: center;
  }

  .search-container {
    width: 90%;
    margin: 10px 0;
  }

  #search {
    width: 100%;
    box-sizing: border-box;
  }

  .controls {
    margin: 10px 0;
  }

  button {
    padding: 6px 12px;
    font-size: 0.8em;
  }

  .legend {
    gap: 8px;
  }

  .legend-item {
    font-size: 0.8em;
  }

  .filter-panel {
    padding: 10px;
  }

  .filter-option {
    padding: 4px 8px;
    font-size: 0.75em;
  }

  .tooltip {
    font-size: 10px;
    padding: 5px 8px;
  }
}

@media (max-width: 480px) {
  .dropdown .dropbtn {
    font-size: 11px;
    padding: 6px 4px;
    min-width: 36px;
  }

  .library-title div:first-child {
    font-size: 15px !important;
  }

  #graph {
    height: 40vh;
    min-height: 280px;
  }

  button {
    padding: 5px 10px;
    font-size: 0.75em;
  }
}
</style>

<!-- ==================== 非 scoped 样式：用于 d3 动态创建的 SVG 节点/连线/文字 ==================== -->
<style>
.node {
  cursor: pointer;
  transition: all 0.3s ease;
}

.node circle {
  stroke: #fff;
  stroke-width: 2px;
  transition: all 0.3s ease;
}

.node circle.expandable {
  stroke-dasharray: 3, 3;
}

.node text {
  font-size: 10px;
  text-shadow: 0 0 2px white;
  transition: all 0.3s ease;
  pointer-events: none;
  user-select: none;
}

.link {
  stroke-opacity: 0.9;
  stroke-width: 2.5px;
  transition: all 0.3s ease;
}

.highlight-link {
  stroke-opacity: 1 !important;
  stroke-width: 4px !important;
  filter: drop-shadow(0 0 3px rgba(255, 215, 0, 0.8)) drop-shadow(0 0 6px rgba(255, 255, 0, 0.6));
}

.highlight {
  stroke: #ffcc00 !important;
  stroke-width: 3px !important;
  filter: drop-shadow(0 0 5px rgba(255,204,0,0.7));
}

.highlight-text {
  font-weight: bold !important;
  font-size: 12px !important;
  fill: #006994 !important;
}

.depth-0 { font-size: 16px; font-weight: bold; fill: white; text-shadow: 1px 1px 2px black; }
.depth-1 { font-size: 15px; font-weight: bold; fill: black; }
.depth-2 { font-size: 14px; fill: black; font-weight: bold; }
.depth-3 { font-size: 12px; fill: black; font-weight: bold; }
.depth-4 { font-size: 10px; fill: black; font-weight: bold; }

#info-panel h2 {
  color: #006994;
  border-bottom: 2px solid #4a8bc9;
  padding-bottom: 12px;
  margin-top: 0;
  font-size: 1.6em;
}

#info-panel img {
  max-width: 100%;
  height: auto;
  margin: 15px 0;
  border-radius: 6px;
  box-shadow: 0 3px 6px rgba(0,0,0,0.1);
  transition: all 0.3s ease;
}

#info-panel img:hover {
  transform: scale(1.02);
  box-shadow: 0 5px 10px rgba(0,0,0,0.2);
}

#info-panel p, #info-panel div {
  line-height: 1.7;
  color: #444;
  font-size: 0.95em;
}

#context-menu {
  position: absolute;
  background: white;
  border: 1px solid #ccc;
  box-shadow: 2px 2px 10px rgba(0,0,0,0.2);
  z-index: 1000;
  min-width: 150px;
}

#context-menu div {
  padding: 8px 12px;
  cursor: pointer;
}

#context-menu div:hover {
  background-color: #f0f8ff;
}

#graph svg {
  width: 100%;
  height: 100%;
}

/* ==================== 移动端适配：d3 创建的元素 ==================== */
@media (max-width: 768px) {
  #graph svg {
    width: 100% !important;
    height: 100% !important;
  }

  .depth-0 { font-size: 18px; }
  .depth-1 { font-size: 16px; }
  .depth-2 { font-size: 15px; }
  .depth-3 { font-size: 14px; }
  .depth-4 { font-size: 12px; }

  .node circle {
    stroke-width: 3px;
  }
}

@media (max-width: 480px) {
  .depth-0 { font-size: 16px; }
  .depth-1 { font-size: 14px; }
  .depth-2 { font-size: 13px; }
  .depth-3 { font-size: 12px; }
  .depth-4 { font-size: 11px; }
}
</style>
