var express = require('express');
var router = express.Router();
var disaster_full = require('../data/disaster_full')
var disaster_summary = require('../data/disaster_summary')

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
});

router.get('/report', function(req, res, next) {
  res.render('report', { title: 'Express' });
});

router.get('/disaster_full', function(req, res, next) {
    res.json({data:disaster_full})
})

router.get('/disaster_summary', function(req, res, next) {
    res.json({data:disaster_summary})
})

module.exports = router;
