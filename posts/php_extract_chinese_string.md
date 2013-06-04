php中如何截取中文字符串
=======================

众所周知php原生函数substr是不支持截取中文字符串的。下面的代码提供了多种截取php中文字符串的方法。

#### 1. 截取GB2312中文字符串

	<?php
	< ?php
	//截取中文字符串
	function mysubstr($str, $start, $len) {
		$tmpstr = "";
		$strlen = $start + $len;
		for($i = 0; $i < $strlen; $i++) {
			if(ord(substr($str, $i, 1)) > 0xa0) {
				$tmpstr .= substr($str, $i, 2);
				$i++;
			} else
				$tmpstr .= substr($str, $i, 1);
		}
		return $tmpstr;
	}
	?>

#### 2. 截取utf8编码的多字节字符串

	<?php
	< ?php
	//截取utf8字符串
	function utf8Substr($str, $from, $len)
	{
		return preg_replace('#^(?:[\x00-\x7F]|[\xC0-\xFF][\x80-\xBF]+){0,'.$from.'}'.
						   '((?:[\x00-\x7F]|[\xC0-\xFF][\x80-\xBF]+){0,'.$len.'}).*#s',
						   '$1',$str);
	}
	?>

#### 3. UTF-8、GB2312都支持的汉字截取函数

	<?php
	< ?php
	/*
	Utf-8、gb2312都支持的汉字截取函数
	cut_str(字符串, 截取长度, 开始长度, 编码);
	编码默认为 utf-8
	开始长度默认为 0
	*/
	 
	function cut_str($string, $sublen, $start = 0, $code = 'UTF-8')
	{
		if($code == 'UTF-8')
		{
			$pa = "/[\x01-\x7f]|[\xc2-\xdf][\x80-\xbf]|\xe0[\xa0-\xbf][\x80-\xbf]|[\xe1-\xef][\x80-\xbf][\x80-\xbf]|\xf0[\x90-\xbf][\x80-\xbf][\x80-\xbf]|[\xf1-\xf7][\x80-\xbf][\x80-\xbf][\x80-\xbf]/";
			preg_match_all($pa, $string, $t_string);
	 
			if(count($t_string[0]) - $start > $sublen) return join('', array_slice($t_string[0], $start, $sublen))."...";
			return join('', array_slice($t_string[0], $start, $sublen));
		}
		else
		{
			$start = $start*2;
			$sublen = $sublen*2;
			$strlen = strlen($string);
			$tmpstr = '';
	 
			for($i=0; $i< $strlen; $i++)
			{
				if($i>=$start && $i< ($start+$sublen))
				{
					if(ord(substr($string, $i, 1))>129)
					{
						$tmpstr.= substr($string, $i, 2);
					}
					else
					{
						$tmpstr.= substr($string, $i, 1);
					}
				}
				if(ord(substr($string, $i, 1))>129) $i++;
			}
			if(strlen($tmpstr)< $strlen ) $tmpstr.= "...";
			return $tmpstr;
		}
	}
	 
	$str = "abcd需要截取的字符串";
	echo cut_str($str, 8, 0, 'gb2312');
	?>

#### 4. BugFree 的字符截取函数

	<?php
	< ?php
	/**
	 * @package     BugFree
	 * @version     $Id: FunctionsMain.inc.php,v 1.32 2005/09/24 11:38:37 wwccss Exp $
	 *
	 *
	 * Return part of a string(Enhance the function substr())
	 *
	 * @author                  Chunsheng Wang <wwccss@263.net>
	 * @param string  $String  the string to cut.
	 * @param int     $Length  the length of returned string.
	 * @param booble  $Append  whether append "...": false|true
	 * @return string           the cutted string.
	 */
	function sysSubStr($String,$Length,$Append = false)
	{
		if (strlen($String) < = $Length )
		{
			return $String;
		}
		else
		{
			$I = 0;
			while ($I < $Length)
			{
				$StringTMP = substr($String,$I,1);
				if ( ord($StringTMP) >=224 )
				{
					$StringTMP = substr($String,$I,3);
					$I = $I + 3;
				}
				elseif( ord($StringTMP) >=192 )
				{
					$StringTMP = substr($String,$I,2);
					$I = $I + 2;
				}
				else
				{
					$I = $I + 1;
				}
				$StringLast[] = $StringTMP;
			}
			$StringLast = implode("",$StringLast);
			if($Append)
			{
				$StringLast .= "...";
			}
			return $StringLast;
		}
	}
	 
	$String = "17test.info 走在中国自动化测试的前沿";
	$Length = "18";
	$Append = false;
	echo sysSubStr($String,$Length,$Append);
	?>

